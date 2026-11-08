package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:time"
import "core:slice"
import "base:intrinsics"
import "core:thread"

// MAX_NUMBER_TO_CALC : i64 : max( i64 )

GIGA_BYTE     :: 1024 * 1024 * 1024
// MAX_MEMORY : i64 : 100 * GIGA_BYTE
MAX_MEMORY    : i64 : 1 * GIGA_BYTE

// CPU Intel Ultra 9 285K

MAX_END_RANGE_METHOD_1 : i64 :       100_000_000      //       100 milions in 7.24 s     ( 100 milions EUA )
MAX_END_RANGE_METHOD_2 : i64 :     1_000_000_000      //     1_000 milions in 319.49 ms  ( 1 billion EUA )
MAX_END_RANGE_METHOD_3 : i64 :     1_000_000_000      //     1_000 milions in 769.3 ms   ( 1 billion EUA )
MAX_END_RANGE_METHOD_4 : i64 :     1_000_000_000      //     1_000 milions in 223.8 ms   ( 1 billion EUA )
MAX_END_RANGE_METHOD_5 : i64 : 1_000_000_000_000      // 1_000_000 milions in 1m 7.8s    ( 1 trillion EUA )
MAX_END_RANGE_METHOD_6 : i64 : 1_000_000_000_000      // 1_000_000 milions in 38.5s      ( 1 trillion EUA )


// This uses the Prime Number Theorem in the Legendre form.
//
// pi( a, b ) ~ ( b / ( ln( b ) - 1 ) ) - ( a / ( ln( a ) - 1 ) )
//
// The error in the extimation is below 1 % .
extimates_num_of_primes_in_range :: proc ( start_prime : i64,
	                                       end_prime   : i64 ) ->
                                         ( num_primes : i64 ) {

    num_primes = i64( ( f64( end_prime )   / ( math.ln( f64( end_prime ) )   - 1 ) ) -
                      ( f64( start_prime ) / ( math.ln( f64( start_prime ) ) - 1 ) )
                    )

    // Add the 1 % error
    num_primes += i64( f64( num_primes )  * 0.01 )

    return num_primes
}

main :: proc ( ) {

	// Doest the number of primes fit inside the memory so we can store them?

	start_range : i64 = 1
	end_range   : i64 = MAX_END_RANGE_METHOD_1

	extimated_num  := extimates_num_of_primes_in_range( start_range, end_range )
	extimated_size := extimated_num * size_of( i64 )
    fmt.printfln( "The extimated number of primes is %d, and uses %d bytes ",
                  extimated_num, extimated_size )
	if extimated_size > MAX_MEMORY {

		fmt.printfln( "ERROR: The data needed to store the primes number is bigger then the" +
			          " MAX_MEMORY %d Giga bytes in the settings", MAX_MEMORY / GIGA_BYTE )
		os.exit( -1 )
	}

	// Allocate the dynamic colletion to store the primes.
	// Nota: Falta dar margem de segurança.
	primes_data, err := make( [dynamic]i64, len = 0, cap = extimated_num )
	if err != .None {

		// fmt.printfln( "ERROR: While allocating the primes_data collection." )
		os.exit( -1 )
	}
	defer delete( primes_data )

	// 1 is not a prime number.
	append( & primes_data, i64( 2 ) )

	start_time := time.tick_now( )

	// Calculate the primes, method 1
new_cycle: for i := start_range + 2; i < end_range; i += 2 {

		max_prime_value_that_can_be_macthed : i64 = i64( math.sqrt( f64( i ) ) )
		// fmt.printfln( "Candidate to prime %d, max_prime_value_that_can_be_macthed : %d",
		//               i, max_prime_value_that_can_be_macthed )

		for prev_prime in primes_data[ 1 : ] {

			if  prev_prime > max_prime_value_that_can_be_macthed {

				break
			}

			// All number not prime are multiple of any other prime lower then SQRT( n ).
			// The primes are like the atoms of Mathematics.

			if i % prev_prime == 0 {

				// fmt.printfln( "Not a prime %d", i )

				// Not a prime, because a prime can not be a multiple of any other prime.
				continue new_cycle
			}
		}

		append( & primes_data, i64( i ) )
	}

	elapsed_time := time.tick_since( start_time )

    /*
	fmt.printfln( "Primes:" )
	out_start_range := 0
	out_end_range   := min( len( primes_data ),  1_000 )
	for prime in primes_data[ out_start_range : out_end_range ] {

		fmt.printfln( "%d", prime )
	}
	*/

	// The total number of primes

	fmt.printfln( "\nTotal number of primes[ 2, %d ] : %d\n",
                  end_range,
	 	          len( primes_data ) )
	fmt.printfln( "Some primes:\n\n %v \n %v \n",
                  primes_data[  : 10 ],
                  primes_data[ len( primes_data ) - 10 :  ] )

	fmt.printfln( "Elapsed_time: %v", elapsed_time )




	// Method 2    sieve_segmented
	fmt.printfln( "\n==> Method : sieve_segmented \n" )

	start_time_m2 := time.tick_now( )

    counter_primes_m2 := sieve_segmented( MAX_END_RANGE_METHOD_2 )

	elapsed_time_m2 := time.tick_since( start_time_m2 )

	fmt.printfln( "\nTotal number of primes[ 2, %d ] : %d\n",
                  MAX_END_RANGE_METHOD_2,
	 	          counter_primes_m2 )

	fmt.printfln( "Elapsed_time method_2: %v", elapsed_time_m2 )




	// Method 3     sieve_segmented  1 bit packing
	fmt.printfln( "\n==> Method : sieve_segmented_1_bit_packing \n" )

	start_time_m3     := time.tick_now( )

    counter_primes_m3 := sieve_segmented_1_bit_packing( MAX_END_RANGE_METHOD_3 )

	elapsed_time_m3   := time.tick_since( start_time_m2 )

	fmt.printfln( "\nTotal number of primes[ 2, %d ] : %d\n",
                  MAX_END_RANGE_METHOD_3,
	 	          counter_primes_m3 )

	fmt.printfln( "Elapsed_time method_3: %v", elapsed_time_m3 )




	// Method 4     sieve_segmented_fast
	fmt.printfln( "\n==> Method : sieve_segmented_fast \n" )

	start_time_m4     := time.tick_now( )

    counter_primes_m4 := sieve_segmented_fast( MAX_END_RANGE_METHOD_4 )

	elapsed_time_m4   := time.tick_since( start_time_m4 )

	fmt.printfln( "\nTotal number of primes[ 2, %d ] : %d\n",
                  MAX_END_RANGE_METHOD_4,
	 	          counter_primes_m4 )

	fmt.printfln( "Elapsed_time method_4: %v", elapsed_time_m4 )



	// Method 5     Parallel 24 core sieve_segmented
	fmt.printfln( "\n==> Method : Parallel 24 core sieve_segmented \n" )

	start_time_m5     := time.tick_now( )

    counter_primes_m5 := sieve_segmented_parallel( MAX_END_RANGE_METHOD_5 )

	elapsed_time_m5   := time.tick_since( start_time_m5 )

	fmt.printfln( "\nTotal number of primes[ 2, %d ] : %d\n",
                  MAX_END_RANGE_METHOD_5,
	 	          counter_primes_m5 )

	fmt.printfln( "Elapsed_time method_5: %v", elapsed_time_m5 )





	// Method 6     Parallel 24 core SIMD AVX2 sieve_segmented
	fmt.printfln( "\n==> Method : Parallel 24 core SIMD AVX2 sieve_segmented \n" )

	start_time_m6     := time.tick_now( )

    counter_primes_m6 := sieve_segmented_parallel_avx2( MAX_END_RANGE_METHOD_6 )

	elapsed_time_m6   := time.tick_since( start_time_m6 )

	fmt.printfln( "\nTotal number of primes[ 2, %d ] : %d\n",
                  MAX_END_RANGE_METHOD_6,
	 	          counter_primes_m6 )

	fmt.printfln( "Elapsed_time method_6: %v", elapsed_time_m6 )

}



// In a Intel ultra 9 285K theere is L0D 48 KB we will use 32 * 1024 that fits inside it
SEGMENT_SIZE :: 32 * 1024

sieve_segmented :: proc ( limit : i64 ) ->
                        ( count : i64 ) {

    if limit < 2 {

    	return 0
    }

    sqrt_limit := i64( math.sqrt( f64( limit ) ) )
    // Odd max index i is 2 * i + 1
    half_limit : i64 = ( limit - 1 ) / 2

    // Find the primes until sqrt( limit ) ( for 10^9, that goes until 31.622 )
    max_small_i : i64 = ( sqrt_limit - 1 ) / 2
    is_small_comp := make( [ ]bool, max_small_i + 1 )
    defer delete( is_small_comp )

    primes   := make( [dynamic]i64, 0, 3500 )
    // Saves the next index to cross of each prime
    next_idx := make( [dynamic]i64, 0, 3500 )
    defer delete( primes )
    defer delete( next_idx )

    for i : i64 = 1; i <= max_small_i; i += 1 {

        // Is a composite number
        if !is_small_comp[ i ] {

            p     := 2 * i + 1
            start := ( p * p - 1 ) / 2
            for j := start; j <= max_small_i; j += p {

                is_small_comp[ j ] = true
            }
            append( & primes, p )
            append( & next_idx, start )
        }
    }

    // Allocates a single block that fits inside the Cache L1D in the Core Ultra 9 285K
    segment := make( [ ]u8, SEGMENT_SIZE )
    defer delete( segment )

    // Count already with the prime 2
    count = 1

    // Process the interval [ 1 .. half_limit ] in blocks of SEGMENT_SIZE
    for low : i64 = 1; low <= half_limit; low += SEGMENT_SIZE {

        high    : i64 = min( low + SEGMENT_SIZE - 1, half_limit )
        seg_len : i64 = high - low + 1

        // Clear the block in the cache L1 ( 0 = prime, 1 = composite )
        slice.fill( segment[ : seg_len ], 0 )

        // Cross the multiples of each base prime number Risca inside each block
        for idx : i64 = 0; idx < i64( len( primes ) ); idx += 1 {

            p : i64 = primes[ idx ]
            j : i64 = next_idx[ idx ]

            for ; j <= high; j += p {

                segment[ j - low ] = 1
            }

            // Saves where it stoped for the next block ( and there are no rest
            // of integer divisions % that is a slow operation on modern CPUs )
            next_idx[ idx ] = j
        }

        // Count the primes ( zeros ) that have survived the cleasing of primes in this block
        for i : i64 = 0; i < seg_len; i += 1 {

            count += i64( segment[ i ] == 0 )
        }
    }

    return count
}






// 4096 u64 words = 32 KB (fits inside the 48 KB L0D Cache of the Core Ultra 9 285K)
// Each 32 KB block represents 4096 * 64 = 262,144 odd numbers
SEGMENT_WORDS : i64 : 4096
SEGMENT_BITS  : i64 : SEGMENT_WORDS * 64

sieve_segmented_1_bit_packing :: proc ( limit : i64 ) ->
                                      ( count : i64 ) {

    if limit < 2 {

        return 0
    }

    sqrt_limit := i64( math.sqrt( f64( limit ) ) )
    // Odd max index i is 2 * i + 1
    half_limit : i64 = ( limit - 1 ) / 2

    // Find the primes until sqrt( limit ) ( for 10^9, that goes until 31.622 )
    max_small_i : i64 = ( sqrt_limit - 1 ) / 2
    is_small_comp := make( [ ]bool, max_small_i + 1 )
    defer delete( is_small_comp )

    primes   := make( [dynamic]i64, 0, 3500 )
    // Saves the next index to cross of each prime
    next_idx := make( [dynamic]i64, 0, 3500 )
    defer delete( primes )
    defer delete( next_idx )

    for i : i64 = 1; i <= max_small_i; i += 1 {

        // Is a prime number (not composite)
        if !is_small_comp[ i ] {

            p     := 2 * i + 1
            start := ( p * p - 1 ) / 2
            for j := start; j <= max_small_i; j += p {

                is_small_comp[ j ] = true
            }
            append( & primes, p )
            append( & next_idx, start )
        }
    }

    // Allocates a single 32 KB bit-packed block that fits inside the L0D/L1D Cache in the Core Ultra 9 285K
    segment := make( [ ]u64, SEGMENT_WORDS )
    defer delete( segment )

    // Count already with the prime 2
    count = 1

    // Process the interval [ 1 .. half_limit ] in blocks of SEGMENT_BITS
    for low : i64 = 1; low <= half_limit; low += SEGMENT_BITS {

        high      : i64 = min( low + SEGMENT_BITS - 1, half_limit )
        seg_bits  : i64 = high - low + 1
        seg_words : i64 = ( seg_bits + 63 ) >> 6

        // Clear the block in the cache L1 ( bit 0 = prime, bit 1 = composite )
        slice.fill( segment[ : seg_words ], 0 )

        // Cross the multiples of each base prime number inside each block
        for idx : i64 = 0; idx < i64( len( primes ) ); idx += 1 {

            p : i64 = primes[ idx ]
            j : i64 = next_idx[ idx ]

            for ; j <= high; j += p {

                k : i64 = j - low
                segment[ k >> 6 ] |= u64( 1 ) << u64( k & 63 )
            }

            // Saves where it stopped for the next block ( and there are no rest
            // of integer divisions % that is a slow operation on modern CPUs )
            next_idx[ idx ] = j
        }

        // In the last block, mask the spare bits beyond half_limit as composite ( 1 )
        rem_bits : i64 = seg_bits & 63
        if rem_bits != 0 {

            segment[ seg_words - 1 ] |= ~( ( u64( 1 ) << u64( rem_bits ) ) - 1 )
        }

        // Count the primes ( zero bits ) that survived in this block using hardware POPCNT
        for w : i64 = 0; w < seg_words; w += 1 {

            count += i64( intrinsics.count_ones( ~segment[ w ] ) )
        }
    }

    return count
}






// 128 KB fits comfortably in the 192 KB L1D cache of the Core Ultra 9 285K
// SEGMENT_SIZE_4 : i64 : 128 * 1024
SEGMENT_SIZE_4 : i64 : 32 * 1024

sieve_segmented_fast :: proc ( limit : i64 ) ->
                             ( count : i64 ) {

    if limit < 2 {

        return 0
    }

    sqrt_limit := i64( math.sqrt( f64( limit ) ) )
    half_limit : i64 = ( limit - 1 ) / 2

    max_small_i : i64 = ( sqrt_limit - 1 ) / 2
    is_small_comp := make( [ ]bool, max_small_i + 1 )
    defer delete( is_small_comp )

    primes   := make( [dynamic]i64, 0, 3500 )
    next_idx := make( [dynamic]i64, 0, 3500 )
    defer delete( primes )
    defer delete( next_idx )

    for i : i64 = 1; i <= max_small_i; i += 1 {

        if !is_small_comp[ i ] {

            p     := 2 * i + 1
            start := ( p * p - 1 ) / 2
            for j := start; j <= max_small_i; j += p {

                is_small_comp[ j ] = true
            }
            append( & primes, p )
            append( & next_idx, start )
        }
    }

    segment := make( [ ]u8, SEGMENT_SIZE_4 )
    defer delete( segment )

    count = 1 // Prime 2

    for low : i64 = 1; low <= half_limit; low += SEGMENT_SIZE_4 {

        high    : i64 = min( low + SEGMENT_SIZE_4 - 1, half_limit )
        seg_len : i64 = high - low + 1

        slice.fill( segment[ : seg_len ], 0 )

        for idx : i64 = 0; idx < i64( len( primes ) ); idx += 1 {

            p : i64 = primes[ idx ]
            // Subtract `low` ONCE outside the inner loop
            k : i64 = next_idx[ idx ] - low

            // Unroll 4x for small/medium primes so the CPU executes pure stores
            for ; k <= seg_len - 1 - 3 * p; k += p * 4 {

                segment[ k ]         = 1
                segment[ k + p ]     = 1
                segment[ k + p * 2 ] = 1
                segment[ k + p * 3 ] = 1
            }

            for ; k < seg_len; k += p {

                segment[ k ] = 1
            }

            next_idx[ idx ] = k + low
        }

        // Count 8 bytes at a time as u64, then finish remaining tail bytes
        words64 := ( [^]u64 )( raw_data( segment ) )
        n_words : i64 = seg_len >> 3

        for w : i64 = 0; w < n_words; w += 1 {

            // Each byte is 0 (prime) or 1 (composite).
            // Subtracting the sum of the 8 bytes from 8 gives the prime count in 1 instruction!
            count += 8 - i64( intrinsics.count_ones( words64[ w ] ) )
        }

        for i : i64 = n_words << 3; i < seg_len; i += 1 {

            count += i64( segment[ i ] == 0 )
        }
    }

    return count
}





//
// Parallel version
//


// 32 KB fits inside the 48 KB L0D of the 8 P-Cores AND the 32 KB L1D of the 16 E-Cores
SEGMENT_SIZE_5   : i64 : 32 * 1024
NUM_CORES_5      :: 24

// Each thread claims 64 consecutive segments at a time so it only computes the
// starting `next_idx` once per chunk, then runs 64 blocks with ZERO `%` divisions.
CHUNK_SEGMENTS_5 : i64 : 64
CHUNK_SPAN_5     : i64 : SEGMENT_SIZE_5 * CHUNK_SEGMENTS_5

Worker_Context_Fast :: struct {
    primes      : [ ]i64,
    half_limit  : i64,
    next_chunk  : ^i64, // Shared atomic cursor for dynamic load balancing (P-cores vs E-cores)
    local_count : i64,  // Per-thread prime counter
}

sieve_worker_fast :: proc( t : ^thread.Thread ) {

    ctx        := ( ^Worker_Context_Fast )( t.data )
    primes     := ctx.primes
    half_limit := ctx.half_limit
    num_primes := i64( len( primes ) )

    // Private 32 KB block and next_idx array allocated exclusively for this core
    segment  := make( [ ]u8, SEGMENT_SIZE_5 )
    next_idx := make( [ ]i64, num_primes )
    defer delete( segment )
    defer delete( next_idx )

    local_total : i64 = 0

    for {

        // Atomically grab the next chunk of 64 segments
        chunk_low : i64 = intrinsics.atomic_add( ctx.next_chunk, CHUNK_SPAN_5 )
        if chunk_low > half_limit {

            break
        }

        chunk_high : i64 = min( chunk_low + CHUNK_SPAN_5 - 1, half_limit )

        // Initialize `next_idx` ONCE at the start of the 64-segment chunk
        for idx : i64 = 0; idx < num_primes; idx += 1 {

            p     : i64 = primes[ idx ]
            start : i64 = ( p * p - 1 ) / 2

            if start < chunk_low {

                rem : i64 = ( chunk_low - start ) % p
                if rem == 0 {

                    start = chunk_low
                } else {

                    start = chunk_low + ( p - rem )
                }
            }
            next_idx[ idx ] = start
        }

        // Process the 64 consecutive 32 KB blocks inside this core's L0D/L1D cache
        for low : i64 = chunk_low; low <= chunk_high; low += SEGMENT_SIZE_5 {

            high    : i64 = min( low + SEGMENT_SIZE_5 - 1, chunk_high )
            seg_len : i64 = high - low + 1

            slice.fill( segment[ : seg_len ], 0 )

            for idx : i64 = 0; idx < num_primes; idx += 1 {

                p : i64 = primes[ idx ]
                // Subtract `low` ONCE outside the inner loop
                k : i64 = next_idx[ idx ] - low

                // Unroll 4x for small/medium primes so the CPU executes pure stores
                for ; k <= seg_len - 1 - 3 * p; k += p * 4 {

                    segment[ k ]         = 1
                    segment[ k + p ]     = 1
                    segment[ k + p * 2 ] = 1
                    segment[ k + p * 3 ] = 1
                }

                for ; k < seg_len; k += p {

                    segment[ k ] = 1
                }

                next_idx[ idx ] = k + low
            }

            // Count 8 bytes at a time as u64, then finish remaining tail bytes
            words64 := ( [^]u64 )( raw_data( segment ) )
            n_words : i64 = seg_len >> 3

            for w : i64 = 0; w < n_words; w += 1 {

                // Each byte is 0 (prime) or 1 (composite).
                // Subtracting the sum of the 8 bytes from 8 gives the prime count in 1 instruction!
                local_total += 8 - i64( intrinsics.count_ones( words64[ w ] ) )
            }

            for i : i64 = n_words << 3; i < seg_len; i += 1 {

                local_total += i64( segment[ i ] == 0 )
            }
        }
    }

    ctx.local_count = local_total
}

sieve_segmented_parallel :: proc ( limit : i64 ) ->
                                 ( count : i64 ) {

    if limit < 2 {

        return 0
    }

    sqrt_limit := i64( math.sqrt( f64( limit ) ) )
    half_limit : i64 = ( limit - 1 ) / 2

    max_small_i : i64 = ( sqrt_limit - 1 ) / 2
    is_small_comp := make( [ ]bool, max_small_i + 1 )
    defer delete( is_small_comp )

    primes := make( [dynamic]i64, 0, 3500 )
    defer delete( primes )

    for i : i64 = 1; i <= max_small_i; i += 1 {

        if !is_small_comp[ i ] {

            p     := 2 * i + 1
            start := ( p * p - 1 ) / 2
            for j := start; j <= max_small_i; j += p {

                is_small_comp[ j ] = true
            }
            append( & primes, p )
        }
    }

    // Shared atomic index starting at odd index 1 (number 3)
    next_chunk : i64 = 1

    threads  : [ NUM_CORES_5 ]^thread.Thread
    contexts : [ NUM_CORES_5 ]Worker_Context_Fast

    // Spawn 23 worker threads and run the 24th worker directly on the main thread
    for c := 0; c < NUM_CORES_5; c += 1 {

        contexts[ c ] = Worker_Context_Fast{
            primes      = primes[ : ],
            half_limit  = half_limit,
            next_chunk  = & next_chunk,
            local_count = 0,
        }

        if c < NUM_CORES_5 - 1 {

            threads[ c ] = thread.create( sieve_worker_fast )
            threads[ c ].data = & contexts[ c ]
            thread.start( threads[ c ] )
        }
    }

    // Run worker #24 on the main thread so all 24 cores are 100% utilized
    main_dummy_thread : thread.Thread
    main_dummy_thread.data = & contexts[ NUM_CORES_5 - 1 ]
    sieve_worker_fast( & main_dummy_thread )

    count = 1 // Prime 2

    // Join all worker threads and sum their local counts
    for c := 0; c < NUM_CORES_5; c += 1 {

        if c < NUM_CORES_5 - 1 {

            thread.destroy( threads[ c ] )
        }
        count += contexts[ c ].local_count
    }

    return count
}




//
// Parallel code and Vectorizations with AVX2
//


// 128 KB cuts the 78,497-prime loop overhead by 4x at 1 Trillion (10^12)
SEGMENT_SIZE_AVX2   : i64 : 128 * 1024
NUM_CORES_AVX2      :: 24
// 256 segments per chunk = 32 MB per chunk -> cuts the slow `%` divisions by 16x!
CHUNK_SEGMENTS_AVX2 : i64 : 256
CHUNK_SPAN_AVX2     : i64 : SEGMENT_SIZE_AVX2 * CHUNK_SEGMENTS_AVX2

// Pre-sieve wheel period for the first 7 odd primes: 3 * 5 * 7 * 11 * 13 * 17 * 19 = 4,849,845
PRESIEVE_PRIMES_COUNT :: 6
PRESIEVE_PERIOD       : i64 : 3 * 5 * 7 * 11 * 13 * 17 // 255,255 bytes

Prime_State :: struct {
    p      : i32, // Fits in 32-bit int up to limit = 4 * 10^18! Cuts cache footprint in HALF!
    next_k : i32, // Relative offset from current `low` (fits in i32!)
}

Worker_Context_AVX2 :: struct {
    primes      : [ ]i64,
    presieve    : [ ]u8,
    half_limit  : i64,
    next_chunk  : ^i64,
    local_count : i64,
}

sieve_worker_avx2 :: proc( t : ^thread.Thread ) #no_bounds_check {

    ctx        := ( ^Worker_Context_AVX2 )( t.data )
    primes     := ctx.primes
    presieve   := ctx.presieve
    half_limit := ctx.half_limit
    num_primes := i64( len( primes ) )

    segment_alloc := make( [ ]u8, SEGMENT_SIZE_AVX2 + 64 )
    // Using 32-bit `Prime_State` shrinks the prime state table from 1.25 MB to 628 KB,
    // fitting completely inside the 3 MB L2 cache of each Core Ultra 9 285K core!
    states_alloc  := make( [ ]Prime_State, num_primes )
    defer delete( segment_alloc )
    defer delete( states_alloc )

    segment := raw_data( segment_alloc )
    states  := raw_data( states_alloc )
    pre_ptr := raw_data( presieve )

    local_total : i64 = 0

    for {

        chunk_low : i64 = intrinsics.atomic_add( ctx.next_chunk, CHUNK_SPAN_AVX2 )
        if chunk_low > half_limit {

            break
        }

        chunk_high : i64 = min( chunk_low + CHUNK_SPAN_AVX2 - 1, half_limit )

        // Only include primes whose p*p actually reaches `chunk_high`!
        active_primes : i64 = 0

        for idx : i64 = PRESIEVE_PRIMES_COUNT; idx < num_primes; idx += 1 {

            p     : i64 = primes[ idx ]
            start : i64 = ( p * p - 1 ) / 2

            if start > chunk_high {

                // Since primes are sorted, NO prime after this can hit this chunk!
                break
            }

            if start < chunk_low {

                rem : i64 = ( chunk_low - start ) % p
                if rem == 0 {

                    start = chunk_low
                } else {

                    start = chunk_low + ( p - rem )
                }
            }

            // Store relative offset `start - chunk_low` in compact 32-bit integers
            states[ active_primes ] = Prime_State{
                p      = i32( p ),
                next_k = i32( start - chunk_low ),
            }
            active_primes += 1
        }

        pre_offset : i64 = chunk_low % PRESIEVE_PERIOD

        for low : i64 = chunk_low; low <= chunk_high; low += SEGMENT_SIZE_AVX2 {

            high    : i64 = min( low + SEGMENT_SIZE_AVX2 - 1, chunk_high )
            seg_len : i32 = i32( high - low + 1 )

            // 1. AVX2 256-BIT PRE-SIEVE INITIALIZATION
            for copied : i32 = 0; copied < seg_len; copied += 32 {

                vec := intrinsics.unaligned_load( ( ^#simd[ 32 ]u8 )( pre_ptr[ pre_offset + i64( copied ) : ] ) )
                intrinsics.unaligned_store( ( ^#simd[ 32 ]u8 )( segment[ copied : ] ), vec )
            }

            pre_offset += i64( seg_len )
            if pre_offset >= PRESIEVE_PERIOD {

                pre_offset %= PRESIEVE_PERIOD
            }

            if low == 1 {

                segment[ 0 ] = 0 // 3
                segment[ 1 ] = 0 // 5
                segment[ 2 ] = 0 // 7
                segment[ 4 ] = 0 // 11
                segment[ 5 ] = 0 // 13
                segment[ 7 ] = 0 // 17
            }

            // 2. CROSS MULTIPLES USING COMPACT 32-BIT RELATIVE OFFSETS
            for idx : i64 = 0; idx < active_primes; idx += 1 {

                p : i32 = states[ idx ].p
                k : i32 = states[ idx ].next_k

                for ; k <= seg_len - 1 - 3 * p; k += p * 4 {

                    segment[ k ]         = 1
                    segment[ k + p ]     = 1
                    segment[ k + p * 2 ] = 1
                    segment[ k + p * 3 ] = 1
                }

                for ; k < seg_len; k += p {

                    segment[ k ] = 1
                }

                // Shift `k` relative to the NEXT segment
                states[ idx ].next_k = k - seg_len
            }

            // 3. AVX2 256-BIT VECTORIZED COUNTING
            words64     := ( [^]u64 )( segment )
            n_words     : i64 = i64( seg_len ) >> 3
            n_words_vec : i64 = n_words & ~i64( 3 )

            for w : i64 = 0; w < n_words_vec; w += 4 {

                c0 := intrinsics.count_ones( words64[ w ] )
                c1 := intrinsics.count_ones( words64[ w + 1 ] )
                c2 := intrinsics.count_ones( words64[ w + 2 ] )
                c3 := intrinsics.count_ones( words64[ w + 3 ] )
                local_total += 32 - i64( c0 + c1 + c2 + c3 )
            }

            for w : i64 = n_words_vec; w < n_words; w += 1 {

                local_total += 8 - i64( intrinsics.count_ones( words64[ w ] ) )
            }

            for i : i64 = n_words << 3; i < i64( seg_len ); i += 1 {

                local_total += i64( segment[ i ] == 0 )
            }
        }
    }

    ctx.local_count = local_total
}

sieve_segmented_parallel_avx2 :: proc( limit : i64 ) ->
                                     ( count : i64 ) {

    if limit < 2 {

        return 0
    }

    sqrt_limit := i64( math.sqrt( f64( limit ) ) )
    half_limit : i64 = ( limit - 1 ) / 2

    max_small_i : i64 = ( sqrt_limit - 1 ) / 2
    is_small_comp := make( [ ]bool, max_small_i + 1 )
    defer delete( is_small_comp )

    primes := make( [dynamic]i64, 0, 10000 )
    defer delete( primes )

    for i : i64 = 1; i <= max_small_i; i += 1 {

        if !is_small_comp[ i ] {

            p     := 2 * i + 1
            start := ( p * p - 1 ) / 2
            for j := start; j <= max_small_i; j += p {

                is_small_comp[ j ] = true
            }
            append( & primes, p )
        }
    }

    // Build the 255,255-byte pre-sieve template (+ SEGMENT_SIZE_AVX2 + 64 wrap-around padding
    // so AVX2 loads never need a modulo check inside the segment copy loop)
    presieve_len := PRESIEVE_PERIOD + SEGMENT_SIZE_AVX2 + 64
    presieve     := make( [ ]u8, presieve_len )
    defer delete( presieve )

    for idx := 0; idx < PRESIEVE_PRIMES_COUNT && idx < len( primes ); idx += 1 {

        p := primes[ idx ]
        // Mark all odd multiples of p (at indices k where 2*k + 1 is divisible by p)
        for k : i64 = ( p - 1 ) / 2; k < presieve_len; k += p {

            presieve[ k ] = 1
        }
    }

    next_chunk : i64 = 1

    threads  : [ NUM_CORES_AVX2 ]^thread.Thread
    contexts : [ NUM_CORES_AVX2 ]Worker_Context_AVX2

    for c := 0; c < NUM_CORES_AVX2; c += 1 {

        contexts[ c ] = Worker_Context_AVX2{
            primes      = primes[ : ],
            presieve    = presieve[ : ],
            half_limit  = half_limit,
            next_chunk  = & next_chunk,
            local_count = 0,
        }

        if c < NUM_CORES_AVX2 - 1 {

            threads[ c ] = thread.create( sieve_worker_avx2 )
            threads[ c ].data = & contexts[ c ]
            thread.start( threads[ c ] )
        }
    }

    main_dummy_thread : thread.Thread
    main_dummy_thread.data = & contexts[ NUM_CORES_AVX2 - 1 ]
    sieve_worker_avx2( & main_dummy_thread )

    count = 1 // Prime 2

    for c := 0; c < NUM_CORES_AVX2; c += 1 {

        if c < NUM_CORES_AVX2 - 1 {

            thread.destroy( threads[ c ] )
        }
        count += contexts[ c ].local_count
    }

    return count
}
