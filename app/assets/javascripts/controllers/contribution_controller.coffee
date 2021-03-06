app = angular.module('Crowdscribed')
app.controller('ContributionController', ['$scope', '$http', ($scope, $http) ->
  $scope.STATE_ABBR_PATTERN = "^[a-zA-Z]{2}$"
  $scope.POSTAL_CODE_PATTERN = "^\\d{5}$"

  $scope.campaignId = null
  $scope.rewards = []
  $scope.selectedRewardId = null
  $scope.selectedReward = null
  $scope.customContributionAmount = null
  $scope.customRewardId = null # reward selected after entering a custom donation amount
  $scope.customReward = null
  $scope.availableRewards = [] # rewards available for a custom amount
  $scope.isInProgress = false

  $scope.$watch 'campaignId', ->
    loadRewards()

  $scope.$watch 'selectedRewardId', ->
    $scope.selectedReward.selected = false if $scope.selectedReward
    $scope.selectedReward = _.find $scope.rewards, (r) ->
      r.id == $scope.selectedRewardId
    if $scope.selectedReward
      $scope.selectedReward.selected = true
      $scope.customContributionAmount = null

  $scope.$watch 'customContributionAmount', ->
    refreshAvailableRewards()

  $scope.$watch 'customRewardId', ->
    $scope.customReward = _.find $scope.availableRewards, (r) ->
      r.id == $scope.customRewardId

  $scope.handleRewardClick = (e) ->
    $scope.selectedRewardId = $(e.currentTarget).data('reward-id')

  $scope.clearSelection = () ->
    $scope.selectedRewardId = null
  $scope.addressRequired = () ->
    _.chain([$scope.selectedReward, $scope.customReward]).
      some((r) -> r && r.physical_address_required).
      value()

  $scope.submitForm = () ->
    $scope.isInProgress = true
    $('#progressbar').progressbar
      max: 3
      value: 0
    $('#payment-button').click()
    return


  specifiedAmount = () ->
    if $scope.selectedReward
      $scope.selectedReward.minimum_contribution
    else
      $scope.customContributionAmount

  handlePaymentReceived = (details)->
    $('#progressbar').progressbar 'option', 'value', 1
    createPayment(details.nonce)
    return

  createPayment = (nonce) ->
    url = "/payments.json"
    data =
      payment:
        amount: specifiedAmount()
        nonce: nonce
    $http.post(url, data).then (response) ->
      $('#progressbar').progressbar 'option', 'value', 2
      createContribution(response.data.id)
    , (error) ->
      console.log "Unable to create the payment."
      console.log error
      return


  createContribution = (paymentId) ->
    url = "/campaigns/#{$scope.campaignId}/contributions.json"
    data =
      contribution:
        amount: specifiedAmount(),
        email: $scope.email,
        payment_id: paymentId
      fulfillment:
        reward_id: $scope.selectedRewardId || $scope.customRewardId,
        email: $scope.email,
        address1: $scope.address1,
        address2: $scope.address2,
        city: $scope.city,
        state: $scope.state,
        postal_code: $scope.postalCode,
        recipient: $scope.recipient

    $http.post(url, data).then (response) ->
      $('#progressbar').progressbar 'option', 'value', 3
      window.redirectTo "/contributions/#{response.data.public_key}"
    , (error) ->
      console.log "Unable to create the contribution."
      console.log error

  loadRewards = ->
    if $scope.campaignId
      url = "/campaigns/#{$scope.campaignId}/rewards.json"
      $http.get(url).then (response)->
        $scope.rewards = response.data
        $scope.selectedRewardId = $scope.rewards[0].id if $scope.rewards.length > 0
      , (error)->
        console.log "Unable to get the rewards."
        console.log error
    else
      $scope.rewards = []

  refreshAvailableRewards = ->
    if $scope.customContributionAmount
      $scope.availableRewards = _.filter $scope.rewards, (r) ->
        r.minimum_contribution <= $scope.customContributionAmount
    else
      $scope.availableRewards = []

  window.redirectTo = (url) ->
    window.location.href = url


  # this is only appropriate when the payment provider
  # is brain tree. Need to figure out how to include it
  # selectively

  $(() ->
    window.paymentReceivedCallbacks.add(handlePaymentReceived))

  return
])
