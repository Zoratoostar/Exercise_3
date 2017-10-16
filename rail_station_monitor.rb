
class Station
  attr_reader :name, :trains

  def initialize(name)
    @name = name.to_s
    @trains = []
  end

  def receive_train(trn)
    if trn.class == Train && !(trains.include? trn)
      trains << trn
      trn
    end
  end

  def send_train(trn)
    trains.delete(trn)
  end

  def get_trains(passanger_or_freight)
    trains.select { |trn| trn.typeof_train == passanger_or_freight }
  end

  def count_trains(passanger_or_freight)
    get_trains(passanger_or_freight).count
  end

  def list_trains(typeof_train)
    if typeof_train == :all
      trains.map &:to_s
    else
      get_trains(typeof_train).map &:to_s
    end
  end

  def to_s
    name
  end
end

class Train
  attr_reader :unique_number, :typeof_train, :route
  attr_accessor :countof_carriages, :speed, :current_station_index

  def initialize(uid, carriages, pass_or_frei)
    @unique_number = uid.to_s
    @countof_carriages = carriages.to_i
    if pass_or_frei == :passenger
      @typeof_train = :passenger
    elsif pass_or_frei == :freight
      @typeof_train = :freight
    end
    @speed = 0
  end

  def add_speed(amount)
    self.speed += amount
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
      self.current_station_index = 0
      route.stations.first.receive_train(self)
    end
  end

  def next_station
    route.stations[current_station_index + 1]
  end

  def previous_station
    if current_station_index > 0
      route.stations[current_station_index - 1]
    end
  end

  def shift_forward
    if next_station
      route.stations[current_station_index].send_train(self)
      self.current_station_index += 1
      route.stations[current_station_index].receive_train(self)
    end
  end

  def shift_backward
    if previous_station
      route.stations[current_station_index].send_train(self)
      self.current_station_index -= 1
      route.stations[current_station_index].receive_train(self)
    end
  end
end

class Route
  attr_reader :stations

  def initialize(initial_station, final_station)
    if initial_station.class == Station && final_station.class == Station && initial_station != final_station
      @stations = [initial_station, final_station]
    end
  end

  def add_station(stn)
    if stn.class == Station
      final_station = stations.pop
      stations.push(stn, final_station)
    end
  end

  def delete_station(stn)
    stations.delete(stn)
  end

  def list_stations
    stations.map &:to_s
  end
end
