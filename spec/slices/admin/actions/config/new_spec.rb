# frozen_string_literal: true

RSpec.describe Admin::Controllers::Config::New, type: :action do
  init_controller_spec

  it "rediret to root" do
    response = action.call(params)
    expect(response[0]).to eq 302
    expect(response[1]["Location"]).to eq "/"
  end

  describe "before initialized" do
    let(:config_repository_stubs) { {current: nil} }

    it "is successful" do
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end
end
