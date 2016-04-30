class UserDecorator < Draper::Decorator
  delegate_all

  def name_decorated
  	Rails.cache.fetch("#{cache_key}/#{self.class.name}/#{__method__}") do
  	  "#{name} decorated"
  	end
  end

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
