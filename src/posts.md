---
layout: page
title: Posts

---

<ul>
  <% collections.posts.resources.each do |post| %>
    <li>
      <%= link_to post.data.title, post.relative_url %>
    </li>
  <% end %>
</ul>

If you have a lot of posts, you may want to consider adding [pagination](https://www.bridgetownrb.com/docs/content/pagination)!
