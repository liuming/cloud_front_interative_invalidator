require 'aws-sdk'
require 'table_print'

require_relative "cloud_front_interative_invalidator/version"

module CloudFrontInterativeInvalidator
  def self.start(params={})
    tp.set :max_width, 100

    if ENV['AWS_ACCESS_KEY_ID'].nil?
      puts "Input AWS access key id:"
      ENV['AWS_ACCESS_KEY_ID'] = gets.chomp
    end

    if ENV['AWS_SECRET_ACCESS_KEY'].nil?
      puts "Input AWS secret access key:"
      ENV['AWS_SECRET_ACCESS_KEY'] = gets.chomp
    end

    AWS.config({
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
    })

    list_distributions
  end

  def self.list_distributions(options={})
    distributions = []
    AWS::CloudFront::Client.new.list_distributions[:items].each_with_index do |item, index|
      distributions << { number: index + 1, id: item[:id], domain_name: item[:domain_name], origins: item[:origins][:items].map{|i| i[:domain_name]}.join(',') }
    end
    tp distributions

    begin
      puts "Input the number of the distribution (or anything else to quit):"
      distribution_input = gets.chomp
      return unless distribution_input.match(/^[0-9]+$/)
      distribution_index = distribution_input.to_i - 1
    end until distribution_index < distributions.size && distribution_index > 0
    distribution_id = distributions[distribution_index][:id]
    show_distribution(distribution_id) if distribution_id
  end

  def self.show_distribution(distribution_id)
    #tp AWS::CloudFront::Client.new.get_distribution(id: distribution_id).data
    puts "Distribution #{distribution_id} selected."
    puts "l/list: list invalidations"
    puts "c/create: create invalidations"
    puts "q/quit: quit current step"
    actions = {
      /^(l|list)$/ => :list_invalidations,
      /^(c|create)$/ => :create_invalidation,
      /^(q|quit)$/ => :list_distributions,
    }
    action = gets.chomp
    method_name = actions.select{|k,v| k.match(action)}.values.first
    send(method_name, distribution_id)
  end

  def self.list_invalidations(distribution_id=nil)
    begin
      invalidations = AWS::CloudFront::Client.new.list_invalidations(distribution_id: distribution_id)
      tp invalidations[:items]
      puts "Refresh? (y/n)"
    end while gets.chomp.downcase == 'y'
    invalidation_id = nil
    #get_invalidation(distribution_id, invalidation_id)
    show_distribution(distribution_id)
  end

  def self.create_invalidation(distribution_id)
    puts "Input the path to be invalidated:"
    paths = []
    paths << gets.chomp
    options = {distribution_id: distribution_id, invalidation_batch: { paths: { quantity: paths.size, items: paths } , caller_reference: rand.to_s }}
    tp AWS::CloudFront::Client.new.create_invalidation(options).data
    show_distribution(distribution_id)
  end

  def self.get_invalidation(distribution_id, invalidation_id)
    tp AWS::CloudFront::Client.new.get_invalidation(distribution_id: distribution_id, id: invalidation_id).data
  end
end
