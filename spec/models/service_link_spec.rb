require 'spec_helper'

describe ServiceLink do
  it { should belong_to(:linked_to_service) }

  describe 'validations' do

    it { should validate_presence_of :alias }
    it { should validate_presence_of :linked_to_service }

    describe 'uniqueness validations' do
      before do
        # we need a record in the DB for the uniqueness validations to work
        to = Service.create!(name: 'to')
        from = Service.create!(name: 'from')
        ServiceLink.create!(
          linked_to_service: to,
          linked_from_service_id: from.id,
          alias: 'link'
        )
      end

      it { should validate_uniqueness_of(:linked_to_service).scoped_to(:linked_from_service_id) }
    end

    describe 'linking to itself' do
      before do
        subject.alias = 'alias'
      end

      it 'errors when linked to and from ids match' do
        subject.linked_from_service_id = 3
        subject.linked_to_service_id = 3
        expect(subject.valid?).to be_false
        expect(subject.errors[:base]).to include "can't link to self"
      end

      it 'does not error if one of the ids is nil' do
        subject.linked_to_service = Service.new
        expect(subject.valid?).to be_true
      end
    end
  end

  describe '#link_string' do
    let(:linked_to_service) { Service.new(name: 'mysql') }

    before do
      subject.alias = 'DB'
      subject.linked_to_service = linked_to_service
    end

    it 'returns the docker link string fragment' do
      expect(subject.link_string).to eql 'mysql:DB'
    end
  end
end
