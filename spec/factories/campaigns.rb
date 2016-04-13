FactoryGirl.define do
  factory :campaign, aliases: [:active_campaign] do
    book
    target_amount 1_234
    target_date { Date.today + 30 }
    state 'active'
    factory :unstarted_campaign do
      state 'unstarted'
    end
    factory :collected_campaign do
      state 'collected'
    end
    factory :collecting_campaign do
      state 'collecting'
    end
    factory :cancelling_campaign do
      state 'cancelling'
    end
    factory :cancelled_campaign do
      state 'cancelled'
    end
  end
end
