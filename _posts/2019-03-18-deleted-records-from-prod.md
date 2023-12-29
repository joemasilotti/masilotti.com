---
title: I just deleted 2500 records from production 😬
date: 2019-03-18
description: 1249 records in prod. 3775 records in dev. Something's not right.
---

I woke up yesterday eager to add pretty social shares to my side project, [weTabletop](https://www.wetabletop.com). As I plugged a few URLs into the [Twitter Card Validator](https://cards-dev.twitter.com/validator) a few started to 404. Oddly, the records seemed to be fine in my development database running a production dump from late last week.

![No! My records!](/assets/images/deleted-records-from-prod/missing-records.jpg){:standalone}

## Time to sanity check

Something was going on. Did I somehow delete a bunch of records from production?

To verify I remoted in to the Heroku Rails console and started debugging. Comparing table counts with those in dev taught me that the `events` table was out of sync. By a lot.

I figured out _which_ records were missing by comparing the IDs of all records in production to a normal database sequence (1, 2, 3, 4, etc.). I very rarely actually delete events, so any gaps in the pattern will show something wrong.

```ruby
(irb)> ((1..Event.last.id).to_a - (Event.first.id..Event.last.id).to_a).count
=> 2526
```

I had somehow lost over 2500 records. 😭

## Backups? What backups?

Ideally, this would be fixed by merging a database backup into the current dataset in production. I could have downloaded a dump from a week ago, found all the records, and uploaded those back to prod.

However, to keep Heroku expenses as low as possible I don't pay for the [$50 database add-on](https://elements.heroku.com/addons/heroku-postgresql), the cheapest one that supports automatic backups. So no automated backups for me. 🤠

Luckily, my dataset is still very small (~30k records) so I can pull production into development every now and then. And my most recent dump was from before the random deletions started occurring! While not perfect, I figured I can write a script to manually export and import the records from development to production.

## Export/import raw JSON

1. Get the IDs of missing records (from before)
2. Write each record to a file, as JSON
3. Upload the file and an import script to production
4. Parse each line and `#create!` a new record

Exporting the _entire_ record to JSON (bypassing any custom serializers) ensures all the data is preserved. This includes the record's ID and timestamps, something you usually don't want to carry over when moving data.

This is one of the rare times you actually want that data. I needed the backups to look just like the records they were restoring. Event #412 should be marked as created on Feb 14, not Mar 18 (today).

### The exporter, run in development

```ruby
class EventJSONExporter
  def export
    ids = [1, 2, 3, ...].freeze # pasted in from before

    File.open("db/events.json", "wb") do |file|
      Event.where(id: ids).find_each do |event|
        file.write event.to_json
        file.write "\n"
      end
    end
  end
end
```

### The importer task, run in production

```ruby
namespace :events do
  desc "Import deleted events from JSON file."
  task import_json: :environment do
    saved_event_ids = Set.new
    filename = Rails.root.join "db", "events.json"

    File.open(filename).each_line do |line|
      begin
        event = Event.new(JSON.parse line)
        event.save!
        saved_event_ids << event.id
      rescue JSON::ParserError
        puts "Couldn't parse JSON: #{line}"
      rescue StandardError => e
        puts "Couldn't save event #{line["id"]}: #{e}"
      end
    end

    puts "Imported #{saved_event_ids.count} events:"
    puts saved_event_ids
  end
end
```


## Root cause analysis

None of this matters if the records continue to magically delete themselves. A rigorous seach for `destroy` and `delete` through the entire codebase lead me to a single culprit: the Google Calendar event importer.

```ruby
class GoogleCalendarEventImporter
  # ...

  def create_or_update_event(google_calendar_event)
    event = Event.find_or_initialize_by i_cal_uid: e.i_cal_uid
    if google_calendar_event.cancelled? && event.persisted?
      event.delete
    end
    # ...
  end
end
```

Looks fairly innocent, right? If the Google Calendar event was cancelled then delete it from the database.

Turns out `i_cal_uid` can be `nil` when the event is cancelled. Only ~10% of all events are from Google Calendar, the other 90% never get an `i_cal_uid`! This leads to `#find_or_initialize_by` finding _any_ of the other 90% of the events and deleting that one. And this code is run every time a synced calendar is updated — a lot.

In their defense, [Google does document](https://developers.google.com/calendar/v3/reference/events) that the `iCalUID` can be blank for cancelled events. However, it was noted under the `status` section, not where I expected it near the `iCalUID` reference.

> **status**: Deleted events are only guaranteed to have the id field populated.

## Fixes and looking forward

The quick fix is to _not_ delete the record when the Google Calendar event is cancelled. I made this change and deployed to ensure I didn't lose any more data.

```ruby
def create_or_update_event(google_calendar_event)
  if google_calendar_event.cancelled?
    return # TODO: Remove cancelled events by e.id, not iCalID
  end
  # ...
end
```

But this event is still, well, cancelled. It shouldn't be shown to anyone. The code will need to additionally track the Google event ID for each record and only delete if there is a match.

> **What's the difference between `id` and `i_cal_uid`?** Every event has a unique `id` per calender and repeating events all share the same `i_cal_uid`.

## How to prevent this

Phew. In the end I restored all but 17 records; I'll have to manually re-create those myself. But still, I never want to have to do this again. Here are some ways this could have been avoided:

1. A better understanding of the API contract with Google
2. More aggressive alerting when destructive actions occur
3. Better unit tests that handle when `i_cal_uid` is `nil`

At best this post helps someone recover from a similiar data loss. At worst it shows how easily a full-time developer with almost a decade of experience can make such a huge mistake!

Enjoy my humility but please spend the $50 for a database with a backup strategy. 🙏
