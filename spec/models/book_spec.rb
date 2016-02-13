require 'rails_helper'

RSpec.describe Book, type: :model do
  let (:author) { FactoryGirl.create(:author) }
  let (:image) { FactoryGirl.create(:image, author: author) }
  let (:image_file) { Rails.root.join('spec', 'fixtures', 'files', 'author_photo.jpg') }
  let (:attributes) do
    {
      author_id: author.id,
      title: 'About Me',
      short_description: "It's about me",
      long_description: Faker::Lorem.paragraph
    }
  end

  it 'can be created from valid attributes' do
    book = Book.new attributes
    expect(book).to be_valid
  end

  describe 'author_id' do
    it 'is required' do
      book = Book.new attributes.except(:author_id)
      expect(book).to have_at_least(1).error_on :author_id
    end
  end

  describe 'title' do
    it 'is required' do
      book = Book.new attributes.except(:title)
      expect(book).to have_at_least(1).error_on :title
    end

    it 'cannot be more than 255 characters' do
      book = Book.new attributes.merge title: "x" * 256
      expect(book).to have_at_least(1).error_on :title

      book = Book.new attributes.merge title: "x" * 255
      expect(book).to be_valid
    end
  end

  describe 'short description' do
    it 'is require' do
      book = Book.new attributes.except :short_description
      expect(book).to have_at_least(1).error_on :short_description
    end

    it 'cannot be more than 1000 characters' do
      book = Book.new attributes.merge short_description: "x" * 1001
      expect(book).to have_at_least(1).error_on :short_description

      book = Book.new attributes.merge short_description: "x" * 1000
      expect(book).to be_valid
    end
  end

  describe 'cover_image_file' do
    it 'creates a new image record in the database' do
      expect do
        book = Book.new attributes.merge(cover_image_file: image_file)
        book.save!
      end.to change(Image, :count).by 1
    end

    it 'creates a new image_binary record in the database' do
      expect do
        book = Book.new attributes.merge(cover_image_file: image_file)
        book.save!
      end.to change(ImageBinary, :count).by 1
    end

    it 'sets the cover_image_id value of the book record' do
      book = Book.new attributes.merge(cover_image_file: image_file)
      book.save!
      expect(book.cover_image_id).not_to be_nil
    end
  end
end
