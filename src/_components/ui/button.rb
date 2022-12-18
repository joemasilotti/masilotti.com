class Ui::Button < SiteComponent
  attr_reader :title, :href, :icon, :properties

  def initialize(variant = :primary, title: nil, href: nil, icon: nil, class_name: nil, **properties)
    @variant, @title, @href, @icon, @class_name, @properties =
      variant, title, href, icon, class_name, properties
  end

  def class_name
    class_map(
      "inline-flex items-center gap-2 justify-center rounded-md py-2 px-3 text-sm outline-offset-2 transition active:transition-none no-underline" => true,
      variant_class_name[variant] => true,
      @class_name => true
    )
  end

  private

  def variant
    (@variant == :secondary) ? :secondary : :primary
  end

  def variant_class_name
    {
      primary: "bg-zinc-800 font-semibold text-zinc-100 hover:bg-zinc-700 active:bg-zinc-800 active:text-zinc-100/70",
      secondary: "bg-zinc-50 font-medium text-zinc-900 hover:bg-zinc-100 active:bg-zinc-100 active:text-zinc-900/60"
    }
  end
end
