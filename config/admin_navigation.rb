SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'

  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav'
    if administrator_signed_in?
      primary.item :subscribers, 'Subscribers', admin_subscribers_path
      primary.item :inquiries, inquiry_nav_item_caption, admin_inquiries_path
      primary.item :users, 'Users', admin_users_path
      primary.item :approvals, 'Approvals', '#' do |approvals|
        approvals.item :bios, bio_nav_item_caption, admin_bios_path
        approvals.item :books, book_nav_item_caption, admin_book_versions_path
      end
      primary.item :campaigns, 'Campaigns', admin_campaigns_path
      primary.item :payments, 'Payments', admin_payments_path
      primary.item :rewards, 'Rewards', '#' do |rewards_item|
        rewards_item.item :manage_rewards, 'Manage Rewards', admin_house_rewards_path
        rewards_item.item :reward_fulfillment, 'Reward fulfillment', admin_fulfillments_path
      end
      primary.item :sign_out, 'Sign out', destroy_administrator_session_path, method: :delete
    end
  end
end
