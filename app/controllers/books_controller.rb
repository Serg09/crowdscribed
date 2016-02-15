class BooksController < ApplicationController
  before_filter :load_book, only: [:show, :edit, :update]
  before_filter :load_author, only: [:new, :create]
  respond_to :html

  def index
    @author = Author.find(params[:author_id]) if params[:author_id].present?
    @books = administrator_signed_in? ?
      Book.all :
      @author.try(:books)
  end

  def show
    authorize! :show, @book
  end

  def new
    @book = Book.new author_id: @author.id
    authorize! :create, @book
  end

  def create
    @book = @author.books.new(book_params)
    authorize! :create, @book
    flash[:notice] = 'Your book has been submitted successfully.' if @book.save
    respond_with @book
  end

  def edit
    authorize! :update, @book
  end

  def update
    authorize! :update, @book
    @book.update_attributes book_params
    flash[:notice] = 'The book was updated successfully.' if @book.save
    respond_with @book
  end

  private

  def book_params
    params.require(:book).permit(:title, :short_description, :long_description, :cover_image_file)
  end

  def load_author
    @author = Author.find(params[:author_id])
  end

  def load_book
    @book = Book.find(params[:id])
  end
end
