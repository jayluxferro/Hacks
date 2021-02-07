#!/usr/bin/python

import dbus
import dbus.service
import dbus.glib
import gobject
import os

class ScreenDbusObj(dbus.service.Object):
    def __init__(self):
        session_bus = dbus.SessionBus()
        bus_name=dbus.service.BusName("org.gnome.ScreenSaver",bus=session_bus)
        dbus.service.Object.__init__(self,bus_name, '/org/gnome/ScreenSaver')

    @dbus.service.method("org.gnome.ScreenSaver")
    def Lock(self):
        os.system( "xscreensaver-command -lock" )


if __name__ == '__main__':
    object=ScreenDbusObj()
    gobject.MainLoop().run()
