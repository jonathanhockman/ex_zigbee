defmodule ExZigbee.FrameTypes.ExplicitRx do

  defstruct src_ext_address: nil, 
            src_short_address: nil, 
            src_endpoint: nil, 
            dest_endpoint: nil, 
            cluster: nil, 
            profile: nil, 
            payload: nil

  def parse([add1, add2, add3, add4, add5, add6, add7, add8, short1, short2, se, de, cluster1, cluster2, pro1, pro2, options | payload]) do
    %__MODULE__{
      src_ext_address: {add1, add2, add3, add4, add5, add6, add7, add8},
      src_short_address: {short1, short2},
      src_endpoint: se,
      dest_endpoint: de,
      cluster: {cluster1, cluster2},
      profile: {pro1, pro2},
      payload: payload
    }
  end
end