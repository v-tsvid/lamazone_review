class CategoriesController < ApplicationController
  load_and_authorize_resource

  def show
    @categories = Category.all
    @books = @category.books.page(params[:page]).per(6)
  end
end
