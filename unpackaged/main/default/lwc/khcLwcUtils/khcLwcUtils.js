/*
@name KhcLwcUtils
@description: My Komen shared Scripts for LWC components
*/
export function formatString( format, args ) {
    return format.replace(/{(\d+)}/g, function(match, number) { 
        return typeof args[number] != 'undefined'
          ? args[number] 
          : match
        ;
    });
}

export function validateRequiredFields( inputComps ){
  const allValid = [...inputComps]
        .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
  return allValid;
}

export function getCurrentUrlPath () {
    let currentPath = window.location.pathname;
    if ( currentPath && currentPath != '/s/' ) {
        return currentPath.replace('/', '%2F');;
    }
}

export function msToTime(s) {
  var ms = s % 1000;
  s = (s - ms) / 1000;
  var secs = s % 60;
  s = (s - secs) / 60;
  var mins = s % 60;
  var hrs = (s - mins) / 60;
  hrs = hrs < 10 ? ('0' + hrs ) : hrs;
  mins = mins < 10 ? '0' + mins : mins;
  secs = secs < 10 ? '0' + secs : secs;
  return hrs + ':' + mins + ':' + secs;
}

/**
 *
 * @param now a Date object with the current date and time.
 * @param date a Date object with the appointment Data
 * @param time a Time object with the appointment time
 * @returns {boolean} True if appointment is the same day as today AND after the current time. False otherwise.
 * @description This function can be used for any object and is not specific to appointments.
 */

export function isAppointmentLaterToday(now, date, time) {

    if(!date) {
        return false;
    }

    let temp = (new Date(date));
    let appointmentDate = new Date(temp.getTime() + temp.getTimezoneOffset() * 60000);

    let appointmentTime = time !== null ? msToTime(time) : time;

    let appointmentIsLaterToday = false;

    //check if appointment is later on today
    if (appointmentDate.getDate() === now.getDate() && appointmentDate.getFullYear() === now.getFullYear()
        && appointmentTime !== null) {

        let hours = now.getHours();
        let minutes = now.getMinutes();
        let appointmentTimeArray;

        appointmentTimeArray = (appointmentTime).split(":");

        if (parseInt(appointmentTimeArray[0]) > hours) {
            appointmentIsLaterToday = true;
        }
        else if (parseInt(appointmentTimeArray[0]) === hours) {
            if (parseInt(appointmentTimeArray[1]) > minutes) {
                appointmentIsLaterToday = true;
            }
        }
    }

    return appointmentIsLaterToday;
}