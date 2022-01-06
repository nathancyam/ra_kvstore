import Config

config :ra_kvstore,
  leader: :"leader@nathan-ThinkPad-X1-Carbon-Gen-9",
  bootstrap_delay: 1_000

config :ra,
  data_dir: '/home/nathan/Development/ra_kvstore/wal'
