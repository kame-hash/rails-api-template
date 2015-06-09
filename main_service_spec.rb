# services/main_service_spec.rb
require 'rails_helper'

RSpec.describe MainService do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }
  let(:valid_params) { { title: 'Example title', content: 'Example content' } }
  let(:invalid_params) { { title: '' } }

  describe '#create_resource' do
    context 'with valid params' do
      it 'returns the created resource' do
        expect(MainService.new(user).create_resource(valid_params)).to be_present
      end

      it 'calls the #authorize method' do
        expect_any_instance_of(MainService).to receive(:authorize).with(user, :create)
        MainService.new(user).create_resource(valid_params)
      end
    end

    context 'with invalid params' do
      it 'raises a ValidationException' do
        expect { MainService.new(user).create_resource(invalid_params) }.to raise_error(MainService::ValidationException)
      end
    end

    context 'without permissions' do
      it 'raises a NotAuthorizedError' do
        expect { MainService.new(user).create_resource(valid_params) }.not_to raise_error
        expect { MainService.new(FactoryBot.create(:user)).create_resource(valid_params) }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe '#update_resource' do
    let(:resource) { FactoryBot.create(:resource) }

    context 'with valid params' do
      it 'returns the updated resource' do
        expect(MainService.new(admin).update_resource(resource, valid_params)).to be_present
      end

      it 'calls the #authorize method' do
        expect_any_instance_of(MainService).to receive(:authorize).with(admin, :update, resource)
        MainService.new(admin).update_resource(resource, valid_params)
      end
    end

    context 'with invalid params' do
      it 'raises a ValidationException' do
        expect { MainService.new(admin).update_resource(resource, invalid_params) }.to raise_error(MainService::ValidationException)
      end
    end
  end
end