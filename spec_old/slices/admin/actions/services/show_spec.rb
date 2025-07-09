# frozen_string_literal: true

RSpec.describe Admin::Actions::Services::Show do
  init_action_spec
  let(:action_opts) { {service_repository: service_repository} }
  let(:action_params) { {id: "service1"} }
  let(:service_repository_stubs) { {exist_by_name?: true} }

  it "is failure" do
    response = action.call(params)
    expect(response.status).to eq 403
  end

  describe "admin" do
    let(:user) { User.new(**user_attributes, clearance_level: 5) }
    let(:client) { "127.0.0.1" }

    it "is successful" do
      response = action.call(params)
      expect(response.status).to eq 200
    end

    it "is successful with * for new" do
      response = action.call({**params, id: "*"})
      expect(response.status).to eq 200
    end

    it "is failure with !" do
      response = action.call({**params, id: "!"})
      expect(response.status).to eq 400
    end

    describe "not existed" do
      let(:service_repository_stubs) { {exist_by_name?: false} }

      it "is failure" do
        response = action.call(params)
        expect(response.status).to eq 404
      end
    end
  end

  describe "redirect no login session" do
    let(:session) { {uuid: uuid} }

    it "is error" do
      response = action.call(params)
      expect(response.status).to eq 302
      expect(response.headers["Location"]).to eq "/"
    end
  end
end
