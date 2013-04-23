# encoding: utf-8

require 'core_extensions'
require 'driver'
require 'strategy'

class StrategyFactory
  def self.getStrategyHash(host)
    filename = Rails.root+"db/plugin/"+(host+".yml")
    if File.file?(filename)
      return YAML.load_file(filename)
    else
      raise ArgumentError, "Cannot find any strategy for host '#{host}'."
    end
  end

  def self.make(context, mapping, strategies)
    steps = replaceXpaths(mapping, strategies)
    s = Strategy.new(context) {}

    s.step('run') do
      if account.new_account
        open_url URL
        run_step('account_creation')
        run_step('unlog')
      end
      open_url URL
      run_step('login')
      run_step('empty_cart')
      order.products_urls.each do |url|
        open_url url
        run_step('add_to_cart')
      end
      run_step('finalize_order')
      assess next_step:'waitAck'
    end
    s.step('waitAck') do
      if response.content == Strategy::YES_ANSWER
        run_step('payment')
      end
      terminate
    end

    for name, actions in steps
      block = eval "Proc.new do #{actions} end"
      s.step(name,&block)
    end

    return OpenStruct.new context: context, strategy: s
  end

  def self.replaceXpaths(mapping, strategies)
    steps = {}
    for sname, actions in strategies
      for fieldname, xpath in mapping[sname]
        steps[sname] = actions.gsub(/ #{fieldname}/, " #{xpath}")
      end
    end
    return steps
  end

  def self.make_rb_file(host)
    hash = getStrategyHash(host)
    mapping, strategies = hash["mapping"], hash["strategies"]
    vendor = host.gsub(/www.|.com|.fr/,"").gsub(".","_")
    File.open(File.expand_path("../vendors/"+vendor+".rb",__FILE__), "w") do |f|
      f.puts "# encoding: utf-8"
      f.puts
    f.puts "class "+vendor.camelize
      f.puts "\tURL = 'http://#{host}'"
      f.puts
      f.puts "\tattr_accessor :context, :strategy"
      f.puts "", <<-INIT
  def initialize context
    @context = context
    @strategy = instanciate_strategy
  end

  def instanciate_strategy
    Strategy.new(@context) do

      step('run') do
        if account.new_account
          open_url URL
          run_step('account_creation')
          run_step('unlog')
        end
        open_url URL
        run_step('login')
        message Strategy::MESSAGES[:logged], :next_step => 'run2'
      end

      step('run2') do
        run_step('empty_cart')
        message Strategy::MESSAGES[:cart_emptied], :next_step => 'run3'
      end

      step('run3') do
        order.products_urls.each do |url|
          open_url url
          run_step('add_to_cart')
        end
        open_url URL
        run_step('finalize_order')
        assess next_step:'waitAck'
      end

      step('waitAck') do
        if response.content == Strategy::YES_ANSWER
          run_step('payment')
        end
        terminate
      end

  INIT
      for name, actions in strategies
        f.puts "\t\t\tstep('#{name}') do"
        for fieldname, xpath in mapping[name]
          f.puts "\t\t\t\t#{fieldname} = '#{xpath}'"
        end
        f.puts
        f.puts actions.prepend("\t\t\t\t").gsub("<\\n>","\n\t\t\t\t")
        f.puts "\t\t\tend"
        f.puts
      end
      f.puts "\t\tend"
      f.puts "\tend"
      f.puts "end"
    end
  end

  def self.test
    Object.send(:remove_const, :Priceminister) if Object.const_defined?(:Priceminister)
    make_rb_file("www.priceminister.com")
    context = { 'account' => {'email' => 'marie_rose_15@yopmail.com', 'login' => "lksisks352", 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                'order' => {'products_urls' => ["http://www.priceminister.com/offer/buy/18405935/Les-Choristes-CD-Album.html"],
                            'credentials' => {
                              'holder' => 'MARIE ROSE', 
                              'number' => '101290129019201', 
                              'exp_month' => 1,
                              'exp_year' => 2014,
                              'cvv' => 123}},
                'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                           'mobile_phone' => '0634562345',
                           'land_phone' => '0134562345',
                           'first_name' => 'Pierre',
                           'gender' => 0,
                           'last_name' => 'Legrand',
                           'address' => { 'address_1' => '12 rue des lilas',
                                          'address_2' => '',
                                          'additionnal_address' => '',
                                          'zip' => '75019',
                                          'city' => 'Paris',
                                          'country' => 'France'}
              }
    }
    load "lib/strategies/vendors/priceminister.rb"
    s = Priceminister.new(context).strategy
    s.self_exchanger = s.logging_exchanger = s.exchanger = ""
    s.exchanger.stubs(:publish).returns("")
    s.products << "http://www.priceminister.com/offer/buy/204229912/willpower-will-i-am.html#xtatc=PUB-[PMC]-[H]-[Musique]-[Push]-[2]-[Pdts]-[]"
    return s
  end
end



__END__

o = BDD.get(id)
s = StrategyFactory.make(o)
