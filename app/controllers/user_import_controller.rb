class UserImportController < ApplicationController

  def index
  end

  def create
  	# => simply using first user as the batch owner
    result = UserImportService.new(params[:file], User.first).perform()
    redirect_to :back, notice: result
  end

end
