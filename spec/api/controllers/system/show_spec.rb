# frozen_string_literal: true

RSpec.describe Api::Controllers::System::Show do
  init_controller_spec(self)
  let(:action) { Api::Controllers::System::Show.new(**action_opts) }
  let(:format) { 'application/json' }

  it 'is successful' do
    response = action.call(params)
    expect(response[0]).to eq 200
    expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).to eq({
      url: 'http://0.0.0.0:2300/',
      title: 'title',
      domain: 'kyokyo-u.ac.jp',
      contact: {name: nil, email: nil, phone: nil},
      app: {name: 'Yuzakan', version: '0.6.0',
            license: File.read(File.join(__dir__, '../../../../LICENSE')),},
    })
  end

  describe 'other config' do
    let(:config) {
      Config.new(title: 'title2', session_timeout: 3600, contact_name: 'admin', contact_email: 'admin@examle.jp',
                 contact_phone: '00-0000-0000', domain: 'kyokyo-u.ac.jp')
    }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).to eq 200
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        url: 'http://0.0.0.0:2300/',
        title: 'title2',
        domain: 'kyokyo-u.ac.jp',
        contact: {name: 'admin', email: 'admin@examle.jp', phone: '00-0000-0000'},
        app: {name: 'Yuzakan', version: '0.6.0',
              license: File.read(File.join(__dir__, '../../../../LICENSE')),},
      })
    end
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).to eq 200
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        url: 'http://0.0.0.0:2300/',
        title: 'title',
        domain: 'kyokyo-u.ac.jp',
        contact: {name: nil, email: nil, phone: nil},
        app: {name: 'Yuzakan', version: '0.6.0',
              license: File.read(File.join(__dir__, '../../../../LICENSE')),},
      })
    end
  end
end
