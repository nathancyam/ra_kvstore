# RaKvstore

This repository is a naive demonstration using the `ra` Erlang library to create a replicated key-value store utilising the Raft protocol. Additionally, `libcluster` is also used to attach nodes to the cluster, although with some caveats listed towards the end.

## Installation

This project assumes that you have Elixir installed.

```bash
$ mix deps.get
```

Once the dependencies are installed, we can start the application across various nodes or terminal sessions locally. This is handled by `libcluster`.

> Erlang distribution is a vast and complex topic, and will not be covered here.

## Starting our cluster

In a terminal session, we can start the leader node:

```bash
# Leader

$ iex --sname leader --cookie test -S mix
Erlang/OTP 24 [erts-12.1.4] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit]


13:52:06.639 [info]  starting :ra
 
13:52:06.642 [info]  Application ra exited: :stopped
 
13:52:06.648 [info]  ra: starting system default
 
13:52:06.648 [debug] ra: starting system default with config: %{
  data_dir: './wal/leader@localhost',
  name: :default,
  names: %{
    closed_mem_tbls: :ra_log_closed_mem_tables,
    directory: :ra_directory,
    directory_rev: :ra_directory_reverse,
    log_ets: :ra_log_ets,
    log_meta: :ra_log_meta,
    log_sup: :ra_log_sup,
    open_mem_tbls: :ra_log_open_mem_tables,
    segment_writer: :ra_log_segment_writer,
    server_sup: :ra_server_sup_sup,
    wal: :ra_log_wal,
    wal_sup: :ra_log_wal_sup
  },
  segment_max_entries: 4096,
  wal_compute_checksums: true,
  wal_data_dir: './wal/leader@localhost',
  wal_max_batch_size: 8192,
  wal_max_entries: :undefined,
  wal_max_size_bytes: 256000000,
  wal_sync_method: :datasync,
  wal_write_strategy: :default
}
```

In separate terminal sessions, start 2 followers:

```bash
# Follower 1
$ iex --sname f1 --cookie test -S mix
```

```bash
# Follower 2
$ iex --sname f2 --cookie test -S mix
```

A similar output would be shown, but the shell with the leader started should show that a follower joined and was added to the cluster.

With our 3 node setup, (1 leader, 2 followers), we can now read and write to the key-value store. All writes are designated to the leader which are then replicated to the followers via the write-ahead long (WAL). As all mutations are written to the leader, the leader will attempt to write the WAL first before updating its state.


## Reading and writing values

`RaKvstore` exports 3 functions that are pretty self-explanatory:

- `put/2` puts the first argument as the key and the second argument as the value. This will be replicated as described above.
- `get/1` gets the value with the given key from the leader node, via `:ra.consistent_query/2`.
- `local_get/1` gets the value with the given key from any node.

In any of the `iex` sessions, we can call these functions and expect that these entries will be honoured.

## Seeing Raft in action

We can remove follower nodes without much consequence, but if the leader is removed, an election is triggered across the 2 follower nodes.

```bash
14:56:20.216 [info]  {ra_kv,'f2@localhost'}: Leader monitor down with :noconnection, setting election timeout
 
14:56:20.341 [debug] {ra_kv,'f2@localhost'}: pre_vote election called for in term 1
 
14:56:20.343 [debug] state change: pre_vote, no effects required
 
14:56:20.343 [debug] {ra_kv,'f2@localhost'}: follower -> pre_vote in term: 1 machine version: 
```

We can still utilise `iex` to write into our cluster, but these will be transparently delegated to the new leader. We can restart our leader node which most likely will join as a follower. If we were to run our `iex` commands in the restarted shell, we can see that any writes that the new leader had are relayed to the follower.

## Caveats

- Restarting the entire cluster will drop all keys in storage, it does not read from the WAL and rebuild.
- Election can get into a strange state in some conditions. One such example is removing all followers from the leader (i.e. in a 3 node cluster, 2 followers are down). When this occurs the leader runs into a election loop.

