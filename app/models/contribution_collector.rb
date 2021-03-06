# Collects campaign contributions by executing PayPal
# transactions that have already been authorized
class ContributionCollector
  @queue = :normal

  def self.perform(campaign_id, attempt_number = 1)
    Rails.logger.info "Collecting contributions for campaign #{campaign_id}"

    campaign = Campaign.find(campaign_id)
    unless campaign.collect_contributions
      if attempt_number < maximum_attempt_count
        Rails.logger.warn "At least one contribution could not be collected for #{campaign_id}. Trying again at #{2.hours.from_now}"
        Resque.enqueue_in(2.hours, ContributionCollector, campaign_id, attempt_number + 1)
      else
        Rails.logger.warn "At least one contribution could not be collected for #{campaign_id}. The maximum number of retries has been reaching. Finalizing the collection now."
        campaign.finalize_collection!
      end
    end
    CampaignMailer.collection_complete(campaign).deliver_now if campaign.collected? && !campaign.author.unsubscribed?

    Rails.logger.info "Completed contribution collection for campaign #{campaign_id}"
  rescue Exceptions::InvalidCampaignStateError
    Rails.logger.warn "Campaign #{campaign_id} is in state '#{campaign.state}' so contributions will not be collected."
  rescue => e
    Rails.logger.error "Unable to complete the collection for campaign_id=#{campaign_id}, #{e.message}, #{e.backtrace.join("\n  ")}"
  end

  private

  def self.maximum_attempt_count
    3
  end
end
