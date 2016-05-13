class CacheController < ApplicationController

	def index
		render plain: index_cache
	end

	def show
		render plain: show_cache
	end

private

	def index_cache
	  Rails.cache.fetch("#{self.class.name}/#{__method__}", expires_in: 10.minutes) do
			"cached #{self.class.name}/#{__method__}"
	  end
	end

	def show_cache
	  Rails.cache.fetch("#{self.class.name}/#{__method__}/#{params[:id]}", expires_in: 10.minutes) do
			"cached #{self.class.name}/#{__method__}/#{params[:id]}"
	  end
	end

end
