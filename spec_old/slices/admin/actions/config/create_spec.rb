# frozen_string_literal: true

RSpec.describe Admin::Actions::Config::Create do
  init_controller_spec

  it "rediret to root" do
    response = action.call(params)
    expect(response.status).to eq 302
    expect(response.headers["Location"]).to eq "/"
  end

  # RSpec.describe 'before initialized' do
  #   before do
  #     db_clear
  #   end

  #   after do
  #     db_clear
  #   end

  #   let(:config_repository) { instance_double('ConfigRepository', current: nil) }

  #   it 'is successful' do
  #     response = action.call(params)
  #     flash = action.exposures[:flash]

  #     expect(response.status).to eq 200
  #     expect(flash[:errors]).to be_empty
  #   end
  # end
end
