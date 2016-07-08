require 'rails_helper'

RSpec.describe ContributionsController, type: :controller do
  let (:campaign) { FactoryGirl.create(:campaign) }
  let!(:physical_reward) { FactoryGirl.create(:physical_reward, campaign: campaign) }
  let!(:electronic_reward) { FactoryGirl.create(:electronic_reward, campaign: campaign) }

  let (:payment_attributes) do
    {
      credit_card_number: '4444111144441111',
      credit_card_type: 'visa',
      expiration_month: '5',
      expiration_year: '2020',
      first_name: 'Sally',
      last_name: 'Readerton',
      cvv: '123',
      billing_address_1: '1234 Main Str',
      billing_address_2: 'Apt 227',
      billing_city: 'Dallas',
      billing_state: 'TX',
      billing_postal_code: '75200',
      billing_country_code: 'US'
    }
  end

  let (:physical_fulfillment_attributes) do
    {
      reward_id: physical_reward.id,
      first_name: 'John',
      last_name: 'Doe',
      address1: 'PO BOX 42',
      city: 'Dallas',
      state: 'TX',
      postal_code: '75201',
      country_code: 'US'
    }
  end

  describe 'get :new' do
    it 'is successful' do
      get :new, campaign_id: campaign
      expect(response).to have_http_status :success
    end
  end

  describe 'post :create' do
    # in JSON it will perform full creation and require all attributes in one post
    # in HTML it builds the contribution one step at a time

    context 'when a reward is selected' do
      it 'redirects to the :payment action' do
        post :create, campaign_id: campaign,
                      fulfillment: { reward_id: physical_reward.id },
                      contribution: {}
        expect(response).to redirect_to payment_contribution_path(Contribution.last, reward_id: physical_reward.id)
      end
    end

    context 'when an amount is entered' do
      it 'redirects to the :reward action' do
        post :create, campaign_id: campaign,
                      fulfillment: {},
                      contribution: { amount: 100}
        expect(response).to redirect_to reward_contribution_path(Contribution.last)
      end
    end

    it 'creates a contribution record' do
      expect do
        post :create, campaign_id: campaign,
                      fulfillment: {},
                      contribution: { amount: 100}
      end.to change(campaign.contributions, :count).by(1)
    end
  end

  context 'with an incipient contribution' do
    let (:contribution) { FactoryGirl.create(:incipient_contribution, campaign: campaign) }

    describe 'get :edit' do
      it 'is successful' do
        get :edit, id: contribution
        expect(response).to have_http_status :success
      end
    end

    describe 'patch :update' do
      let (:contribution) do
        FactoryGirl.create(:incipient_contribution, campaign: campaign,
                                                    amount: 101)
      end

      context 'when a reward is selected' do
        it 'redirects to the :payment action' do
          patch :update, id: contribution,
            fulfillment: { reward_id: physical_reward.id },
            contribution: {}
          expect(response).to redirect_to payment_contribution_path(Contribution.last, reward_id: physical_reward.id)
        end

        it 'updates the contribution' do
          expect do
            patch :update, id: contribution,
              fulfillment: { reward_id: physical_reward.id },
              contribution: {}
            contribution.reload
          end.to change(contribution, :amount).from(101).to(physical_reward.minimum_contribution)
        end
      end

      context 'when an amount is entered' do
        it 'redirects to the :reward action' do
          expect do
            patch :update, id: contribution,
              fulfillment: {},
              contribution: { amount: 201 }
            contribution.reload
          end.to change(contribution, :amount).to(201)
        end
      end
    end

    describe 'get :reward' do
      it 'is successful' do
        get :reward, id: contribution
        expect(response).to have_http_status :success
      end
    end

    describe 'patch :set_reward' do
      it 'redirects to the payment action' do
        patch :set_reward, id: contribution, fulfillment: { reward_id: electronic_reward.id }
        expect(response).to redirect_to payment_contribution_path(contribution, reward_id: electronic_reward.id)
      end
    end

    describe 'get :payment' do
      it 'is successful' do
        get :payment, id: contribution
        expect(response).to have_http_status :success
      end
    end

    describe 'patch :pay' do
      it 'changes the contribution status to "collected"' do
        expect do
          patch :pay, id: contribution,
                      fulfillment: {},
                      contribution: { email: Faker::Internet.email },
                      payment: payment_attributes
          contribution.reload
        end.to change(contribution, :state).from('incipient').to('collected')
      end

      it 'creates a payment record' do
        expect do
          patch :pay, id: contribution,
                      fulfillment: {},
                      contribution: { email: Faker::Internet.email },
                      payment: payment_attributes
        end.to change(Payment, :count).by(1)
      end

      it 'creates a transaction record' do
        expect do
          patch :pay, id: contribution,
                      fulfillment: {},
                      contribution: { email: Faker::Internet.email },
                      payment: payment_attributes
        end.to change(PaymentTransaction, :count).by(1)
      end

      context 'when an electronic reward is specified' do
        it 'creates a fulfillment record' do
          expect do
            patch :pay, id: contribution,
              fulfillment: { reward_id: electronic_reward.id },
              contribution: { email: Faker::Internet.email },
              payment: payment_attributes
          end.to change(ElectronicFulfillment, :count).by(1)
        end
      end

      context 'when a physical reward is specified' do
        it 'creates a fulfillment record' do
          expect do
            patch :pay, id: contribution,
              fulfillment: physical_fulfillment_attributes,
              contribution: { email: Faker::Internet.email },
              payment: payment_attributes
          end.to change(PhysicalFulfillment, :count).by(1)
        end
      end
    end
  end

  shared_examples :invalid_request do
    describe 'get :reward' do
      it 'redirects to the user profile' do
        get :reward, id: contribution
        expect(response).to redirect_to user_root_path
      end
    end

    describe 'patch :set_reward' do
      it 'redirects to the user profile' do
        patch :set_reward, id: contribution, fulfillment: { reward_id: electronic_reward.id }
        expect(response).to redirect_to user_root_path
      end
    end

    describe 'get :payment' do
      it 'is redirects to the user profile' do
        get :payment, id: contribution
        expect(response).to redirect_to user_root_path
      end
    end

    describe 'patch :pay' do
      it 'is redirects to the user profile' do
        patch :pay, id: contribution,
                    fulfillment: {},
                    contribution: { email: Faker::Internet.email },
                    payment: payment_attributes
        expect(response).to redirect_to user_root_path
      end

      it 'does not create a payment' do
        expect do
          patch :pay, id: contribution,
                      fulfillment: {},
                      contribution: { email: Faker::Internet.email },
                      payment: payment_attributes
        end.not_to change(Payment, :count)
      end
    end
  end

  context 'with a pledged contribution' do
    include_examples :invalid_request do
      let (:contribution) { FactoryGirl.create(:pledged_contribution) }
    end
  end
end