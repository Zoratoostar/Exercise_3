
class Station
  attr_reader :name, :stand_trains

  def initialize(name)
    @name = name.to_s
    @stand_trains = []
  end

  def receive_train(train)
    if train.class == Train && !(stand_trains.include? train)
      @stand_trains << train
      return train
    end
  end

  def send_train(train)
    @stand_trains.delete(train)
  end

  def list_trains(typeof_train = '')
    typeof_train = typeof_train.to_s.downcase
    unless typeof_train.empty?
      if 'passenger'.start_with? typeof_train
        return stand_trains.select { |trn| trn.typeof_train == :passenger }
      elsif 'freight'.start_with? typeof_train
        return stand_trains.select { |trn| trn.typeof_train == :freight }
      end
    end
    return stand_trains
  end

  def list_names(typeof_train = '')
    list_trains(typeof_train).map &:to_s
  end

  def to_s
    name
  end
end

class Train
  attr_reader :unique_number, :typeof_train
  attr_accessor :countof_carriages, :speed
  attr_reader :route, :current_station

  def initialize(uid, carriages, pass_or_frei = 'freight')
    @unique_number = uid.to_s
    @countof_carriages = carriages.to_i
    pass_or_frei = pass_or_frei.to_s.downcase
    unless pass_or_frei.empty?
      if 'passenger'.start_with? pass_or_frei
        @typeof_train = :passenger
      elsif 'freight'.start_with? pass_or_frei
        @typeof_train = :freight
      end
    end
    @speed = 0
  end

  def add_speed(amount)
    self.speed = speed + amount
  end

  def stop
    self.speed = 0
  end

  def hitch_carriage
    self.countof_carriages += 1 if speed == 0
  end

  def unhook_carriage
    if speed == 0 && countof_carriages > 0
      self.countof_carriages -= 1
    end
  end

  def to_s
    unique_number
  end

  def assign_route(route)
    if route.class == Route
      @route = route
      @current_station = route.initial_station
      current_station.receive_train(self)
    end
  end

  def next_station
    list = route.list_stations
    index = list.find_index(current_station)
    if index + 1 < list.length
      return list[index + 1]
    else
      return nil
    end
  end

  def previous_station
    list = route.list_stations
    index = list.find_index(current_station)
    if index > 0
      return list[index - 1]
    else
      return nil
    end
  end

  def shift_forward
    if new_station = next_station
      current_station.send_train(self)
      @current_station = new_station
      current_station.receive_train(self)
    end
  end

  def shift_backward
    if new_station = previous_station
      current_station.send_train(self)
      @current_station = new_station
      current_station.receive_train(self)
    end
  end
end

class Route
  attr_reader :initial_station, :final_station, :transitional_stations

  def initialize(initial_s, final_s)
    if initial_s.class == Station && final_s.class == Station && initial_s != final_s
      @initial_station = initial_s
      @final_station = final_s
      @transitional_stations = []
    end
  end

  def add_transitional_station(station)
    if station.class == Station
      @transitional_stations << station
    end
  end

  def delete_transitional_station(station)
    @transitional_stations.delete(station)
  end

  def list_stations
    list = [initial_station]
    list.concat transitional_stations
    list.push final_station
  end

  def list_names
    list_stations.map &:to_s
  end
end
