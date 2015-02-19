class App < ActiveRecord::Base
  include AppJournal

  has_many :services, dependent: :destroy
  has_many :categories, class_name: 'AppCategory', dependent: :destroy

  before_save :resolve_name_conflicts

  def sorted_services
    @sorted_services ||= ServiceSorter.sort(services)
  end

  def run
    sorted_services.each(&:submit)
    sorted_services.each(&:load)
    sorted_services.each(&:start)
  end

  def restart
    sorted_services.each(&:shutdown)
    sorted_services.each(&:submit)
    sorted_services.each(&:load)
    sorted_services.each(&:start)
  end

  def add_service(params)
    links = Array(params.delete(:links))
    categories = Array(params.delete(:categories))
    service = Service.new(params)

    categories.each do |cat|
      category = self.categories.find { |app_cat| app_cat.id == cat[:id] }

      service.categories << ServiceCategory.new(
        app_category_id: category.id,
        position: cat[:position]) if category
    end

    links.each do |link|
      linked_to_service = self.services.find do |service|
        service.id == link[:service_id]
      end

      service.links << ServiceLink.new(
        linked_to_service: linked_to_service,
        alias: link[:alias]) if linked_to_service
    end

    self.services << service
    self.save
    service
  end

  private

  def resolve_name_conflicts
    return if persisted?
    sanitized_name = name.gsub('/', '_')
    count = App.where('name LIKE ?', "#{sanitized_name}%").count
    self.name = (count > 0) ? "#{sanitized_name}_#{count}" : sanitized_name
  end

  class ServiceSorter

    def self.sort(services)
      new(services).sort
    end

    def initialize(services)
      @services = services
      @unprocessed = Array.new(services)
      @marked = Set.new
      @sorted = []
    end

    def sort
      @services.each { |service| visit(service) }
      @sorted
    end

    private

    def visit(service)
      if @marked.include?(service)
        raise 'circular link reference'
      end

      if @unprocessed.include?(service)
        @marked.add(service)
        service.links.each { |link| visit(link.linked_to_service) }
        @marked.delete(service)

        @unprocessed.delete(service)
        @sorted << service
      end
    end
  end
end
