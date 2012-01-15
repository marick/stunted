$:.unshift("../lib")
require "stunted"

## This example needs more work.

include Stunted

module Shape
  def shape; "shape"; end
end

reservation_maker = FunctionalHash.make_maker(Shape)

reservation = reservation_maker.(:a => 1, :b => 2)

puts reservation.shape




