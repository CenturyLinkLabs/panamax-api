require 'spec_helper'

describe SharedVolume do
  it { should belong_to(:exported_from_service) }

  describe 'validations' do

    it { should validate_presence_of :exported_from_service }

    describe 'uniqueness validations' do
      before do
        # we need a record in the DB for the uniqueness validations to work
        vol_from = Service.create!(name: 'vol_from')
        mounted_on = Service.create!(name: 'mounted_on')
        SharedVolume.create!(
            exported_from_service: vol_from,
            mounted_on_service_id: mounted_on.id
        )
      end

      it { should validate_uniqueness_of(:exported_from_service).scoped_to(:mounted_on_service_id) }
    end

    describe 'mounting self' do

      it 'errors when volume from and mounted on service ids match' do
        subject.exported_from_service_id = 3
        subject.mounted_on_service_id = 3
        expect(subject.valid?).to be_false
        expect(subject.errors[:base]).to include "can't mount self"
      end

      it 'does not error if one of the ids is nil' do
        subject.exported_from_service = Service.new
        expect(subject.valid?).to be_true
      end
    end
  end

  describe '#exported_from_service_name' do
    let(:exported_from_service) { Service.new(name: 'my_service') }

    before do
      subject.exported_from_service = exported_from_service
    end

    it 'returns the volumes_from service name ' do
      expect(subject.exported_from_service_name).to eql 'my_service'
    end
  end
end
