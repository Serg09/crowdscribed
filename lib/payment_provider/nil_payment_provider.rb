module PaymentProvider
  class NilPaymentProvider
    def create(attributes)
      return_from_file('payment_create_approved).json')
    end

    def capture(authorization_id, amount)
      return_from_file('payment_capture_completed.json')
    end

    def void(authorization_id)
      return_form_file('authorization_void_voided.json')
    end

    private

    def return_from_file(file_name)
      path = Rails.root.join('spec', 'fixtures', 'files', file_name)
      raw = File.read(path)
      json = JSON.parse(raw, symbolize_names: true)
      OpenStruct.new(id: json[:id], state: json[:state], to_json: json)
    end
  end
end
