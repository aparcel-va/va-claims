class UsersController < ApplicationController
  before_action :require_auth

  def index
    @name = @session.id_token_attributes['name']
    name_parts = @name.split(' ')
    @user = TestUser.where('lower(first_name) = ? AND  lower(last_name) = ?', name_parts.first.downcase, name_parts.last.downcase).first
    @user = TestUser.create(first_name: name_parts.first.downcase, last_name: name_parts.last.downcase) unless @user
  end
end
