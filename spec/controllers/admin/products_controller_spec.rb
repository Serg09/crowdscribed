require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do
  let (:book) { FactoryBot.create :book }
  let (:attributes) do
    {
      caption: 'Hardback',
      sku: '0000000000001'
    }
  end

  context 'for an authenticated administrator' do
    let (:admin) { FactoryBot.create :administrator }
    before { sign_in admin }

    describe 'get :index' do
      it 'is successful' do
        get :index
        expect(response).to have_http_status :success
      end
    end

    describe 'get :new' do
      it 'is successful' do
        get :new, book_id: book
        expect(response).to have_http_status :success
      end
    end

    describe 'post :create' do
      it 'redirects to the product index page for the book' do
        post :create, book_id: book, product: attributes
        expect(response).to redirect_to admin_book_products_path(book)
      end

      it 'creates the product record' do
        expect do
          post :create, book_id: book, product: attributes
        end.to change(book.products, :count).by(1)
      end
    end

    describe 'delete :destroy' do
      let!(:product) { FactoryBot.create :product, book: book }

      it 'deletes the product' do
        expect do
          delete :destroy, id: product
        end.to change(book.products, :count).by -1
      end

      it 'redirects to the product index for the book' do
        delete :destroy, id: product
        expect(response).to redirect_to admin_book_products_path(book.id)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the home page' do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'get :new' do
      it 'redirects to the home page' do
        get :new, book_id: book
        expect(response).to redirect_to root_path
      end
    end

    describe 'post :create' do
      it 'redirects to the home page' do
        post :create, book_id: book, product: attributes
        expect(response).to redirect_to root_path
      end

      it 'does not create the product record' do
        expect do
          post :create, book_id: book, product: attributes
        end.not_to change(Product, :count)
      end
    end

    describe 'delete :destroy' do
      let!(:product) { FactoryBot.create :product, book: book }

      it 'does not delete the product' do
        expect do
          delete :destroy, id: product
        end.not_to change(Product, :count)
      end

      it 'redirects to the home page' do
        delete :destroy, id: product
        expect(response).to redirect_to root_path
      end
    end
  end
end
