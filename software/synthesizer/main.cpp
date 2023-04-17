#include "include/hidboot.h"
#include "include/usbhub.h"
#include "include/usbh_midi.h"
// Satisfy the IDE, which needs to see the include statment in the ino too.
#ifdef dobogusinclude
#include <spi4teensy3.h>
#endif
#include "include/SPI.h"

void test_loop();
void press_any_key();
void print_hex(int v, int num_places);
void halt55();

/* USB Host Shield 2.0 board quality control routine */
/* To see the output set your terminal speed to 115200 */
/* for GPIO test to pass you need to connect GPIN0 to GPOUT7, GPIN1 to GPOUT6, etc. */
/* otherwise press any key after getting GPIO error to complete the test */
/**/

/* variables */
uint8_t rcode;
uint8_t usbstate;
uint8_t laststate;
//uint8_t buf[sizeof(USB_DEVICE_DESCRIPTOR)];
USB_DEVICE_DESCRIPTOR buf;
USB Usb;


void toBinary(uint8_t a)
{
    uint8_t i;

    for(i=0x80;i!=0;i>>=1)
        printf("%c",(a&i)?'1':'0');
}

extern "C" {
        #include "sgtl5000_test.h"
}

int main() {
	printf("Initializing SGTL5000...\n");
	initialize_sgtl5000();
	printf("Initializing MIDI connection...\n");
	USBH_MIDI Midi(&Usb);
	if(Usb.Init() == -1){
		printf("Halted...");
		while(1);
	}
	delay(200);

	/* Pointers to PIOs */
	int NUM_NOTES = 4;
//	volatile unsigned int *note_vol_0 = (unsigned int*)0x08001200;
//	volatile unsigned int *note_vol_1 = (unsigned int*)0x080011f0;
//	volatile unsigned int *note_vol_2 = (unsigned int*)0x080011e0;
//	volatile unsigned int *note_vol_3 = (unsigned int*)0x080011d0;

	volatile unsigned int* note_vol_array[NUM_NOTES] = {(unsigned int*)0x08001200, (unsigned int*)0x080011f0, (unsigned int*)0x080011e0, (unsigned int*)0x080011d0};
	/* Initialize all notes/volumes to 0 */
//	*note_vol_0 = (unsigned int) 0x3C20;	//C4
//	*note_vol_1 = (unsigned int) 0x4020;	//E4
//	*note_vol_2 = (unsigned int) 0x4320;	//G4
//	*note_vol_3 = (unsigned int) 0;
	for(int i = 0; i < NUM_NOTES; i++)
			*(note_vol_array[i]) = 0;

	int available_idx;
	bool note_used[NUM_NOTES] = {false};
	bool first_note = true;
	while(1){
		Usb.Task();
		if(Midi){
			uint8_t MIDI_packet[ 3 ];
			uint8_t size;

			do {
				if ( (size = Midi.RecvData(MIDI_packet)) > 0 ) {
					/*
					MIDI Status Codes:
					Note On -  1001 CCCC
					Note Off - 1000 CCCC
					*/
//					printf("..........\n");
//					toBinary(MIDI_packet[0]); printf("\n");
//					toBinary(MIDI_packet[1]); printf("\n");
//					toBinary(MIDI_packet[2]); printf("\n");

					switch(unsigned(MIDI_packet[0] >> 4)){
					case 9:						//Note ON
						if(first_note){			//handles an initial data packet that gets interpreted as note on event
							first_note = false;
							break;
						}
						/* Find first available note_vol */
						available_idx = -1;
						for(int i = 0; i < NUM_NOTES; i++){
							if(!note_used[i]){
								available_idx = i;
								note_used[i] = true;
								break;
							}
						}
						/* If a note_vol is available, write to it*/
						if(available_idx != -1)
							*(note_vol_array[available_idx]) = (MIDI_packet[1] << 8) + MIDI_packet[2];
						break;

					case 8:		//Note OFF
						for(int i = 0; i < NUM_NOTES; i++){    								//iterate over all note_vols
							if((*(note_vol_array[i]) >> 8) == unsigned(MIDI_packet[1])){  	//we've found the note to turn off
								*(note_vol_array[i]) = 0;                  					//note turned off
								note_used[i] = false;										//reset flag
								break;
							}
						}
						break;
					}
				}
			} while (size > 0);
		}
	}
}


void test_loop() {
        delay(200);
        Usb.Task();
        usbstate = Usb.getUsbTaskState();
        if(usbstate != laststate) {
                laststate = usbstate;
                /**/
                switch(usbstate) {
                        case( USB_DETACHED_SUBSTATE_WAIT_FOR_DEVICE):
                                E_Notify(PSTR("\r\nWaiting for device..."), 0x80);
                                break;
                        case( USB_ATTACHED_SUBSTATE_RESET_DEVICE):
                                E_Notify(PSTR("\r\nDevice connected. Resetting..."), 0x80);
                                break;
                        case( USB_ATTACHED_SUBSTATE_WAIT_SOF):
                                E_Notify(PSTR("\r\nReset complete. Waiting for the first SOF..."), 0x80);
                                break;
                        case( USB_ATTACHED_SUBSTATE_GET_DEVICE_DESCRIPTOR_SIZE):
                                E_Notify(PSTR("\r\nSOF generation started. Enumerating device..."), 0x80);
                                break;
                        case( USB_STATE_ADDRESSING):
                                E_Notify(PSTR("\r\nSetting device address..."), 0x80);
                                break;
                        case( USB_STATE_RUNNING):
                                E_Notify(PSTR("\r\nGetting device descriptor"), 0x80);
                                rcode = Usb.getDevDescr(1, 0, sizeof (USB_DEVICE_DESCRIPTOR), (uint8_t*) & buf);

                                if(rcode) {
                                        E_Notify(PSTR("\r\nError reading device descriptor. Error code "), 0x80);
                                        print_hex(rcode, 8);
                                } else {
                                        /**/
                                        E_Notify(PSTR("\r\nDescriptor Length:\t"), 0x80);
                                        print_hex(buf.bLength, 8);
                                        E_Notify(PSTR("\r\nDescriptor type:\t"), 0x80);
                                        print_hex(buf.bDescriptorType, 8);
                                        E_Notify(PSTR("\r\nUSB version:\t\t"), 0x80);
                                        print_hex(buf.bcdUSB, 16);
                                        E_Notify(PSTR("\r\nDevice class:\t\t"), 0x80);
                                        print_hex(buf.bDeviceClass, 8);
                                        E_Notify(PSTR("\r\nDevice Subclass:\t"), 0x80);
                                        print_hex(buf.bDeviceSubClass, 8);
                                        E_Notify(PSTR("\r\nDevice Protocol:\t"), 0x80);
                                        print_hex(buf.bDeviceProtocol, 8);
                                        E_Notify(PSTR("\r\nMax.packet size:\t"), 0x80);
                                        print_hex(buf.bMaxPacketSize0, 8);
                                        E_Notify(PSTR("\r\nVendor  ID:\t\t"), 0x80);
                                        print_hex(buf.idVendor, 16);
                                        E_Notify(PSTR("\r\nProduct ID:\t\t"), 0x80);
                                        print_hex(buf.idProduct, 16);
                                        E_Notify(PSTR("\r\nRevision ID:\t\t"), 0x80);
                                        print_hex(buf.bcdDevice, 16);
                                        E_Notify(PSTR("\r\nMfg.string index:\t"), 0x80);
                                        print_hex(buf.iManufacturer, 8);
                                        E_Notify(PSTR("\r\nProd.string index:\t"), 0x80);
                                        print_hex(buf.iProduct, 8);
                                        E_Notify(PSTR("\r\nSerial number index:\t"), 0x80);
                                        print_hex(buf.iSerialNumber, 8);
                                        E_Notify(PSTR("\r\nNumber of conf.:\t"), 0x80);
                                        print_hex(buf.bNumConfigurations, 8);
                                        /**/
                                        E_Notify(PSTR("\r\n\nAll tests passed. Press RESET to restart test"), 0x80);
#ifdef ESP8266
                                                yield(); // needed in order to reset the watchdog timer on the ESP8266
#endif

                                }
                                break;
                        case( USB_STATE_ERROR):
                                E_Notify(PSTR("\r\nUSB state machine reached error state"), 0x80);
                                break;

                        default:
                                break;
                }//switch( usbstate...
        }
}//loop()...

/* constantly transmits 0x55 via SPI to aid probing */
void halt55() {

        E_Notify(PSTR("\r\nUnrecoverable error - test halted!!"), 0x80);
        E_Notify(PSTR("\r\n0x55 pattern is transmitted via SPI"), 0x80);
        E_Notify(PSTR("\r\nPress RESET to restart test"), 0x80);

        while(1) {
                Usb.regWr(0x55, 0x55);
#ifdef ESP8266
                yield(); // needed in order to reset the watchdog timer on the ESP8266
#endif
        }
}

/* prints hex numbers with leading zeroes */
void print_hex(int v, int num_places) {
        int mask = 0, n, num_nibbles, digit;

        for(n = 1; n <= num_places; n++) {
                mask = (mask << 1) | 0x0001;
        }
        v = v & mask; // truncate v to specified number of places

        num_nibbles = num_places / 4;
        if((num_places % 4) != 0) {
                ++num_nibbles;
        }
        do {
                digit = ((v >> (num_nibbles - 1) * 4)) & 0x0f;
                printf("%x\n", digit);
        } while(--num_nibbles);
}

/* prints "Press any key" and returns when key is pressed */
void press_any_key() {
        E_Notify(PSTR("\r\nPress any key to continue..."), 0x80);
//        char x;
//        scanf("%s", &x);
}


