class InquiriesController < ApplicationController
  respond_to :html

  def new
    @inquiry = Inquiry.new
  end

  def create
    @inquiry = Inquiry.new inquiry_params
    if @inquiry.save
      flash[:notice] = 'Your inquiry has been accepted.'
      InquiryMailer.submission_notification(@inquiry).deliver_now
    else
      flash[:alert] = 'We were unable to accept your inquiry.'
    end
    respond_with @inquiry, location: pages_books_path
  end

  def update
  end

  def index
    @inquiries = Inquiry.all
    respond_with @inquiries do |format|
      format.html { render layout: 'admin' }
    end
  end

  def show
    @inquiry = Inquiry.find(params[:id])
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:first_name, :last_name, :email, :body)
  end
end
