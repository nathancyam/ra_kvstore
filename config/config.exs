import Config

config :ra_kvstore,
  nodes: [
    "ra_kv1@nathan-ThinkPad-X1-Carbon-Gen-9",
    "ra_kv2@nathan-ThinkPad-X1-Carbon-Gen-9",
    "ra_kv3@nathan-ThinkPad-X1-Carbon-Gen-9"
  ]

config :ra,
  data_dir: "/tmp/ra_kv"
