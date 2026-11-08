# Primes in Odin - 6 different methods
Having fun with primes, a little journy on how fast can we calc primes on a modern CPU.

## Description
I wanted to have fun with primes in a normal CPU and try to test and explore how much time it would take to calculate the primes on the first 1 trillion numbers (one european billion). The methods are simple and small in nature, so please if you want to know how each method work, study each method code.
They increase there complexity from the start of the coding file until the end. I believe that the know limit for my CPU is in the 6 to 7 seconds for the best code possible, for the first 1 trillion numbers, but I could not achieve that. Note: This CPU is lightlly over clocked.

```Odin
MAX_END_RANGE_METHOD_1        100_000_000  //       100 milions in 7.24 s    ( 100 milions EUA )
MAX_END_RANGE_METHOD_2      1_000_000_000  //     1_000 milions in 0.319 s   ( 1 billion EUA )
MAX_END_RANGE_METHOD_3      1_000_000_000  //     1_000 milions in 0.769 s   ( 1 billion EUA )
MAX_END_RANGE_METHOD_4      1_000_000_000  //     1_000 milions in 0.223 s   ( 1 billion EUA )
MAX_END_RANGE_METHOD_5  1_000_000_000_000  // 1_000_000 milions in 1m 7.8s   ( 1 trillion EUA )
MAX_END_RANGE_METHOD_6  1_000_000_000_000  // 1_000_000 milions in 38.5s     ( 1 trillion EUA )
```

## License
MIT Open Source License

## Have fun
Best regards, <br>
Joao Carvalho
