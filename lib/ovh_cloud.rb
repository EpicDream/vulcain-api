module Ovh

  class Base

    include HTTParty

    @@config = YAML.load_file("#{Rails.root}/config/ovh_cloud.yml")

    def config
      return @@config
    end

    def session
      Rails.cache.fetch([:ovh_session], :expires_in => 15.minutes) do
        @@session = Ovh::Session.new
      end
    end

    def call_api(method, params={})
      params_str = params.present? ? "&params=#{Rack::Utils.escape(params.to_json)}" : ''
      response = HTTParty.get("#{self.config['api_handler']}/#{method}?session=#{self.session.id}#{params_str}")
      if response['error'].present?
        raise RuntimeError, response['error']
      end
      response['answer']
    end
  end

  class Cloud < Base

  # require 'ovh_cloud.rb';  x = Ovh::Cloud.new

    attr_accessor :instances, :tasks

    def initialize
      self.refresh
    end

    def refresh
      self.instances = self.get_instances
      self.tasks = self.get_active_tasks

      task_hash = {}
      self.tasks.each do |t|
        task_hash[t.object_id] = t
      end

      self.instances.each do |i|
        i.task = task_hash[i.id] if task_hash.has_key?(i.id)
      end

      self
    end

    def get_active_tasks(project_name=self.config['project_name'])
      tasks = Ovh::Task::find_all_active(project_name)
    end

    def get_projects
      projects = call_api('getProjects')
    end

    def get_instances(project_name=self.config['project_name'])
      instances = Ovh::Instance.find_all(project_name)
    end

    def get_tasks(project_name=self.config['project_name'])
      tasks = []
      data = call_api('getTasks', {'projectName' => project_name, 'objectTypeName' => 'instance'})
    end

    def get_task(task_id, project_name=self.config['project_name'])
      task_data = call_api('getTask', {'projectName' => project_name, 'taskId' => task_id})
      Ovh::Task.create(task_data, project_name)
    end

    def new_instance_from_image(name, instance_data={})
      task = Ovh::Instance.create(name, instance_data)
      self.refresh
      task
    end

  end

  class Task < Base

    attr_accessor :id, :function, :zone, :progress, :finish_date, :status, :object_id, :comment, :last_update, :object_type, :todo_date, :project_name

    def initialize(project_name=nil)
      self.project_name = project_name || self.config['project_name']
    end

    def self.create(task_data, project_name)
      task = self.new(project_name)
      task.refresh_from_data(task_data)
      task
    end

    def self.find(id, project_name=nil)
      task = self.new
      task.id = id
      task.refresh
      task
    end

    def self.find_all(project_name=nil)
      tasks = []
      virtual = self.new(project_name)
      data = virtual.call_api('getTasks', {'projectName' => virtual.project_name, 'objectTypeName' => 'instance'})
      data.each do |task_data|
        task = self.new(project_name)
        task.refresh_from_data(task_data)
        tasks << task
      end
      tasks
    end

    def self.find_all_active(project_name=nil)
      all_tasks = self.find_all(project_name)
      tasks = []
      all_tasks.each do |task|
        tasks << task if task.status == 'todo'
      end
      tasks
    end

    def refresh
      task_data = call_api('getTask', {'taskId' => self.id, 'projectName' => self.project_name})
      self.refresh_from_data(task_data)
    end

    def refresh_from_data(task_data)
      self.id = task_data['id']
      self.function = task_data['function']
      self.zone = task_data['zone']['name'] if task_data.has_key?('zone')
      self.progress = task_data['progress']
      self.finish_date = task_data['finishDate']
      self.status = task_data['status']
      self.object_id = task_data['objectId']
      self.comment = task_data['comment']
      self.last_update = task_data['lastUpdate']
      self.object_type = task_data['objectType']
      self.todo_date = task_data['todoDate']
      self
    end

  end

  class Instance < Base

    attr_accessor :id, :ipv6, :netmaskv6, :netmaskv4, :ipv4, :status, :name, :distribution_name, :zone_name, :fqdn, :offer_name, :task, :project_name

    def initialize(project_name=nil)
      @project_name = project_name || self.config['project_name']
    end

    def self.find(id, project_name=nil)
      instance = self.new(project_name)
      instance.id = id
      instance.refresh
      instance
    end

    def self.find_all(project_name=nil)
      instances = []
      virtual = self.new(project_name)
      project_name = project_name || virtual.config['project_name']
      data = virtual.call_api('getInstances', {'projectName' => project_name})
      data.each do |instance_data|
        instance = self.new(project_name)
        instance.refresh_from_data(instance_data)
        instances << instance
      end
      instances
    end

    def start
      task_data = self.call_api('startInstance', {'instanceId' => self.id})
      task = Ovh::Task.create(task_data, self.project_name)
      self.task = task
      self
    end

    def stop
      task_data = self.call_api('stopInstance', {'instanceId' => self.id})
      task = Ovh::Task.create(task_data, self.project_name)
      self.task = task
      self
    end

    def self.create(name, instance_data, project_name=nil)
      instance = self.new(project_name)
      instance_data['name'] = name
      ['project_name', 'zone_name', 'offer_name', 'image_name'].each do |param|
        instance_data[param.camelize(:lower)] = instance_data[param] || instance.config[param]
      end
      task_data = instance.call_api('newInstanceFromImage', instance_data)
      task = Ovh::Task.create(task_data, instance.project_name)
      instance.task = task
      instance
    end

    def refresh
      instance_data = call_api('getInstance', {'instanceId' => self.id})
      self.task.refresh if self.task.present? 
      self.refresh_from_data(instance_data)
    end

    def refresh_from_data(instance_data)
      self.id = instance_data['id']
      self.ipv6 = instance_data['ipv6']
      self.netmaskv6 = instance_data['netmaskv6']
      self.netmaskv4 = instance_data['netmaskv4']
      self.ipv4 = instance_data['ipv4']
      self.status = instance_data['status']
      self.name = instance_data['name']
      self.distribution_name = instance_data['distributionName']
      self.zone_name = instance_data['zoneName']
      self.fqdn = instance_data['fqdn']
      self.offer_name = instance_data['offerName']
      self
    end

    def destroy
      task_data = call_api('deleteInstance', {'instanceId' => self.id})
      task = Ovh::Task.create(task_data, self.project_name)
      self.refresh
      self.task = task
      self
    end
  end


  class Session < Base

    attr_accessor :language, :billing_country, :id, :start_date, :login

    def initialize(login=nil, password=nil)
      options = Rack::Utils.escape({'password' => password || self.config['password'], 'login' => login || self.config['login']}.to_json)
      response = HTTParty.get("#{self.config['session_handler']}/login?params=#{options}")
      if response['error'].present?
        raise RuntimeError, response['error']
      end

      @id = response['answer']['id']
      @language = response['answer']['language']
      @billing_country = response['answer']['billingCountry']
      @start_date = response['answer']['startDate']
      @login = response['answer']['login']
    end

  end

end
