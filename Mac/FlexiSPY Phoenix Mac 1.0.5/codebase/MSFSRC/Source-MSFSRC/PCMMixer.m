//
//  PCMMixer.h
//
//  Created by Binh Nguyen (c) Killer Mobile Software
//

#import "PCMMixer.h"
#include <pjlib.h>
#include <pjlib-util.h>
#include <pjmedia.h>
#define MAX_WAV	    64
#define PTIME	    20
#define APPEND	    1000
struct wav_input
{
    const char	    *fname;
    pjmedia_port    *port;
    unsigned	     slot;
    long time;
};

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function"
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-method-access"
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wformat"
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wparentheses"

#import <unistd.h>

#define NSLog(...)
#define THIS_FILE "mixer.c"

#define ENABLE_ECHO_CANCELLER 1

#define CHECK(op)   do { status = op; } while (0)

@implementation PCMMixer

+ (OSStatus) mixFiles:(NSArray*)files atTimes:(NSArray*)times toMixfile:(NSString*)mixfile duration:(long *)duration  {
    
    NSLog(@"*** start mixer %@ %@ %@", files, times, mixfile);
    
    *duration = 0;
    
    pj_caching_pool cp;
    pj_pool_t *pool;
    pjmedia_endpt *med_ept;
    unsigned clock_rate = 8000;
    int c, force=0;
    const char *out_fname;
    pjmedia_conf *conf;
    pjmedia_port *wavout;
    struct wav_input wav_input[MAX_WAV];
    pj_size_t longest = 0, processed;
    unsigned i, input_cnt = 0;
    pj_status_t status;
    
    out_fname = [mixfile UTF8String];
    input_cnt = [files count];
    
    /* Scan input file names */
    for (i =0; i < input_cnt; i++)
    {
        wav_input[i].fname = [files[i] UTF8String];
        wav_input[i].port = NULL;
        wav_input[i].slot = 0;
        wav_input[i].time = [times[i] intValue];
    }
    
    NSLog(@"Out: %s", out_fname);
    
    /* Initialialize */
    CHECK( pj_init() );
    CHECK( pjlib_util_init() );
    pj_caching_pool_init(&cp, NULL, 0);
    CHECK( pjmedia_endpt_create(&cp.factory, NULL, 1, &med_ept) );
    
    pool = pj_pool_create(&cp.factory, "mix", 1000, 1000, NULL);
    
    NSLog(@"Out: %s", out_fname);
    
    /* Create the bridge */
    CHECK( pjmedia_conf_create(pool, MAX_WAV+4, clock_rate, 1,
                               clock_rate * PTIME / 1000, 16,
                               PJMEDIA_CONF_NO_DEVICE, &conf) );
    
    /* Create the WAV output */
    CHECK( pjmedia_wav_writer_port_create(pool, out_fname, clock_rate, 1,
                                          clock_rate * PTIME / 1000,
                                          16, 0, 0, &wavout) );
    
    NSLog(@"Out: %s", out_fname);
    
//    int silences[MAX_WAV]={0};
//    int rsilences[MAX_WAV]={0};
    
    /* Create and register each WAV input to the bridge */
    for (i=0; i<input_cnt; ++i) {
        pj_ssize_t len;
        
        NSLog(@"Fname: %s", wav_input[i].fname);
        
        if (pjmedia_wav_player_port_create(pool, wav_input[i].fname, 20,
                                           PJMEDIA_FILE_NO_LOOP, 0,
                                           &wav_input[i].port) != PJ_SUCCESS)
        {
            // Invalid wav file
            wav_input[i].port = 0;
            continue;
        }
        
        len = pjmedia_wav_player_get_len(wav_input[i].port);
        
        pjmedia_wav_player_info info;
        if (pjmedia_wav_player_get_info (wav_input[i].port, &info) != PJ_SUCCESS)
        {
            // Invalid wav file
            wav_input[i].port = 0;
            continue;
        }
        else {
            if (info.fmt_id != 0 || info.payload_bits_per_sample != 16) {
                // Invalid format
                wav_input[i].port = 0;
                continue;
            }
        }
        
        if (len <= 0) {
            wav_input[i].port = 0;
            continue;
        }
        
        /***/
        
#if ENABLE_ECHO_CANCELLER
        
//        pjmedia_silence_det *det = NULL;
//        
//        pjmedia_silence_det_create(pool, 8000, 320/2, &det);
//        
//        if (det && len > 0)
//        {
//            pj_bool_t silence = PJ_TRUE;
//            
//            pj_int32_t processed = 0;
//            
//            pj_int32_t level = 0;
//            while (processed < len && silence == PJ_TRUE) {
//                
//                pj_int16_t framebuf[PTIME * 48000 / 1000];
//                pjmedia_port *cp = wav_input[i].port;
//                pjmedia_frame frame;
//                
//                frame.buf = framebuf;
//                frame.size = PJMEDIA_PIA_SPF(&cp->info) * 2;
//                pj_assert(frame.size <= sizeof(framebuf));
//                
//                CHECK( pjmedia_port_get_frame(cp, &frame) );
//                
//                silence = pjmedia_silence_det_detect(det, (const pj_int16_t *)frame.buf, frame.size/2, &level);
//                
//                processed += frame.size;
//            }
//            long total = processed/320*20 + [times[i] intValue];
//            
//            NSLog(@"Silence level=%d: %d ms", level, total);
//            
//            silences[i] = total;
//            rsilences[i] = processed/320*20;
//            
//            pjmedia_wav_player_port_set_pos(wav_input[i].port, 0);
//        }
        
#endif
        
//        pj_int32_t avg = pjmedia_calc_avg_signal((const pj_int16_t *)frame.buf, frame.size/2);
//        
//        NSLog(@"First FRAME: %ld", avg);
        
         
         /***/
        
        
        len = (pj_ssize_t)(len * 1.0 * clock_rate /
                           PJMEDIA_PIA_SRATE(&wav_input[i].port->info));
        len = len + ((long)(wav_input[i].time/1000.0*clock_rate) << 2);
        if (len > (pj_ssize_t)longest)
            longest = len;
        
        //PJ_LOG(3,(THIS_FILE, "** Len: %lf", (longest >> 2)*1.0/(clock_rate*1.0) *1000));
        if (wav_input[i].time == 0) {
            CHECK( pjmedia_conf_add_port(conf, pool, wav_input[i].port,
                                         NULL, &wav_input[i].slot));
            //CHECK( pjmedia_conf_connect_port(conf, wav_input[i].slot, 0, 0) );
        }
        else {
            CHECK( pjmedia_conf_add_port(conf, pool, wav_input[i].port,
                                         NULL, &wav_input[i].slot));
        }
    }
    
#if ENABLE_ECHO_CANCELLER
    
    for (i=0; i<input_cnt; ++i) {
        if (wav_input[i].time < 1000) {
            wav_input[i].time = 0;
        }
    }
    
    for (i=0; i<input_cnt; ++i) {
        
        if (wav_input[i].time == 0 && wav_input[i].port != 0) {
            CHECK( pjmedia_conf_connect_port(conf, wav_input[i].slot, 0, 0) );
        }
        
        //NSLog(@"SILENT [%d][%d][%d]", silences[i], rsilences[i], silences[i] - rsilences[i]);
    }

#else
    
    for (i=0; i<input_cnt; ++i) {
        
        if (wav_input[i].time == 0 && wav_input[i].port != 0) {
            CHECK( pjmedia_conf_connect_port(conf, wav_input[i].slot, 0, 0) );
        }
        
        //NSLog(@"SILENT [%d][%d][%d]", silences[i], rsilences[i], silences[i] - rsilences[i]);
    }
    
#endif
    
    NSLog(@"Out: %s", out_fname);
    
    /* Loop reading frame from the bridge and write it to WAV */
    processed = 0;
    while (processed < longest + clock_rate * APPEND * 2 / 1000) {
        for (i=0; i<input_cnt; ++i) {
            if (wav_input[i].time != 0) {
                if (fabs(wav_input[i].time - ((processed >> 2)/(clock_rate*1.0)) * 1000 * 2) <= 10.0) {
                    CHECK( pjmedia_conf_connect_port(conf, wav_input[i].slot, 0, 0) );
                    PJ_LOG(3,(THIS_FILE, "** Connect: %s", wav_input[i].fname));
                }
            }
        }
        
        pj_int16_t framebuf[PTIME * 48000 / 1000];
        pjmedia_port *cp = pjmedia_conf_get_master_port(conf);
        pjmedia_frame frame;
        
        frame.buf = framebuf;
        frame.size = PJMEDIA_PIA_SPF(&cp->info) * 2;
        pj_assert(frame.size <= sizeof(framebuf));
        
        CHECK( pjmedia_port_get_frame(cp, &frame) );
        
        if (frame.type != PJMEDIA_FRAME_TYPE_AUDIO) {
            pj_bzero(frame.buf, frame.size);
            frame.type = PJMEDIA_FRAME_TYPE_AUDIO;
        }
        
        CHECK( pjmedia_port_put_frame(wavout, &frame));
        
        processed += frame.size;
        
        PJ_LOG(3,(THIS_FILE, "** Processed: %lf", ((processed >> 2)/(clock_rate*1.0)) * 1000));
    }
    
    NSLog(@"Done. Output duration: %d.%03d, %lf",
              (processed >> 2)/clock_rate,
              ((processed >> 2)*1000/clock_rate) % 1000, ((processed >> 2)/(clock_rate*1.0)) * 1000 * 2);
    
    *duration = round(((processed >> 2)/(clock_rate*1.0)) * 1000 * 2);
    
    /* Shutdown everything */
    CHECK( pjmedia_port_destroy(wavout) );
    for (i=0; i<input_cnt; ++i) {
        if (wav_input[i].port) {
            CHECK( pjmedia_conf_remove_port(conf, wav_input[i].slot) );
            CHECK( pjmedia_port_destroy(wav_input[i].port) );
        }
    }
    
    CHECK(pjmedia_conf_destroy(conf));
    CHECK(pjmedia_endpt_destroy(med_ept));
    
    pj_pool_release(pool);
    pj_caching_pool_destroy(&cp);
    pj_shutdown();
    
    return 0;
}

@end
