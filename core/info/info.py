# -*- coding: utf-8 -*-
##Pyslvs - Open Source Planar Linkage Mechanism Simulation and Dimensional Synthesis System.
##Copyright (C) 2016-2017 Yuan Chang
##E-mail: pyslvs@gmail.com
##
##This program is free software; you can redistribute it and/or modify
##it under the terms of the GNU Affero General Public License as published by
##the Free Software Foundation; either version 3 of the License, or
##(at your option) any later version.
##
##This program is distributed in the hope that it will be useful,
##but WITHOUT ANY WARRANTY; without even the implied warranty of
##MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##GNU Affero General Public License for more details.
##
##You should have received a copy of the GNU Affero General Public License
##along with this program; if not, write to the Free Software
##Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

from sys import version_info
import platform, argparse
from ..QtModules import *
tr = QCoreApplication.translate
from .Ui_info import Ui_About_Dialog

VERSION = (0, 8, 0, 'dev')
from PyQt5.QtCore import qVersion
from PyQt5.QtCore import PYQT_VERSION_STR as pyqtVersion
from sip import SIP_VERSION_STR as sipVersion
from PyQt5.Qsci import QSCINTILLA_VERSION_STR as qsciVersion
INFO = ["Pyslvs {}.{}.{}({})".format(*VERSION),
    "OS Type: {} {} [{}]".format(platform.system(), platform.release(), platform.machine()),
    "Python Version: {v.major}.{v.minor}.{v.micro}({v.releaselevel})".format(v=version_info),
    "Python Compiler: {}".format(platform.python_compiler()),
    "Qt Version: {}".format(qVersion().strip()),
    "PyQt Version: {}".format(pyqtVersion.strip()),
    "Sip Version: {}".format(sipVersion.strip()),
    "QScintilla Version: {}".format(qsciVersion.strip())]

parser = argparse.ArgumentParser(
    description="Pyslvs - Open Source Planar Linkage Mechanism Simulation and Dimensional Synthesis System.",
    epilog="Power by Python IDE Eric-6, PyQt-5, dxfwrite, Cython, PyZMQ, openpyxl.")
parser.add_argument('-v', '--version', action='version', help="show version infomations and exit", version='{}.{}.{}({})'.format(*VERSION))
parser.add_argument('r', metavar='FILE PATH', default=False, nargs='?', type=str, help="read workbook from the file path")
parser.add_argument('-i', metavar='START PATH', default=False, nargs='?', type=str, help="start Pyslvs in the specified path")
parser.add_argument('-w', action='store_true', help="show rebuild warning of canvas")
parser.add_argument('-f', '--fusion', action='store_true', help="run Pyslvs in Fusion style")
parser.add_argument('--full-screen', action='store_true', help="start Pyslvs with full-screen mode")
parser.add_argument('--file-data', action='store_true', help="display the file data in command-line when opening")
parser.add_argument('--server', metavar='PORT', default=False, nargs='?', type=str, help="start ZMQ server")
parser.add_argument('-d', '--debug-mode', action='store_true', help="do not connect to GUI console when opening")
args = parser.parse_args()

def show_info():
    print('\n'.join(INFO))
    print('-'*7)
    return args

## Turn simple string to html format.
def html(script):
    return '<html><head/><body>{}</body></html>'.format(script)
def title(name, *others):
    return '<h2>{}</h2>'.format(name)+('<h3>{}</h3>'.format('</h3><h3>'.join(others)) if others else '')
def content(*text):
    return '<p>{}</p>'.format('</p><p>'.join(text))
def orderList(*List):
    return '<ul><li>{}</li></ul>'.format('</li><li>'.join(List))

#Splash
class Pyslvs_Splash(QSplashScreen):
    def __init__(self, parent=None):
        super(Pyslvs_Splash, self).__init__(parent, QPixmap(":/icons/Splash.png"))
        self.showMessage("Version {}.{}.{}({})".format(*VERSION), (Qt.AlignBottom|Qt.AlignRight))

#SystemTrayIcon
class Pyslvs_SystemTrayIcon(QSystemTrayIcon):
    def __init__(self, parent=None):
        QSystemTrayIcon.__init__(self, QIcon(QPixmap(":/icons/main_big.png")), parent)
        parent.destroyed.connect(self.hide)
        self.SystemTrayIconMenu = QMenu(parent)
        self.setContextMenu(self.SystemTrayIconMenu)
        if platform.system().lower()=='windows':
            self.setToolTip(tr("Tray icon tool tip", "Pyslvs\nYour solving task will be show here."))
        else:
            self.setToolTip(tr("Tray icon tool tip", html(title('Pyslvs')+content("Your solving task will be show here."))))
        self.action_SystemTrayIconMenu_minimize = QAction("Minimize", self)
        self.action_SystemTrayIconMenu_minimize.setIcon(QIcon(QPixmap(":/icons/minimized.png")))
        self.action_SystemTrayIconMenu_minimize.triggered.connect(parent.showMinimized)
        self.SystemTrayIconMenu.addAction(self.action_SystemTrayIconMenu_minimize)
        self.action_SystemTrayIconMenu_full_screen = QAction("Full screen", self)
        self.action_SystemTrayIconMenu_full_screen.setIcon(QIcon(QPixmap(":/icons/fullscreen.png")))
        self.action_SystemTrayIconMenu_full_screen.triggered.connect(parent.showFullScreen)
        self.SystemTrayIconMenu.addAction(self.action_SystemTrayIconMenu_full_screen)
        self.SystemTrayIconMenu.addSeparator()
        self.action_SystemTrayIconMenu_exit = QAction("Exit", self)
        self.action_SystemTrayIconMenu_exit.setIcon(QIcon(QPixmap(":/icons/exit.png")))
        self.action_SystemTrayIconMenu_exit.triggered.connect(parent.close)
        self.SystemTrayIconMenu.addAction(self.action_SystemTrayIconMenu_exit)
        self.activated.connect(self.clicked)
    
    @pyqtSlot(QSystemTrayIcon.ActivationReason)
    def clicked(self, ActivationReason):
        if ActivationReason==QSystemTrayIcon.Trigger:
            parent = self.parent()
            if parent.isVisible()==True:
                parent.hide()
            else:
                parent.show()

class version_show(QDialog, Ui_About_Dialog):
    def __init__(self, parent=None):
        super(version_show, self).__init__(parent)
        self.setupUi(self)
        self.Title.setText(html(title("Pyslvs")+content("Version {}.{}.{}({}) 2016-2017".format(*VERSION))))
        self.Content.setText(html(content(
            "Pyslvs is a Open Source support tools to help user solving 2D linkage problem.",
            "It can use in Mechanical Design and Simulation.",
            "This program using Python 3 with Python Solvespace.",
            "Pyslvs just like a ordinary CAD software, but use table to add and edit points.",
            "Within changing points location, finally give the answer to designer.",
            "We have these features:")+orderList(
            "2D Linkages dynamic simulation.",
            "Dimensional Synthesis of Planar Four-bar Linkages.",
            "Output points coordinate to Data Sheet (*.csv) format.",
            "Change canvas appearance.",
            "Draw dynamic simulation path with any point in the machinery.",
            "Using triangle iterate the mechanism results.")+content(
            "If you want to know about more, you can reference by our website.")))
        self.Versions.setText(html(orderList(*INFO)))
        self.Arguments.setText(html(content(
            "Startup arguments are as follows:")+orderList(
            "The loaded file when startup: {}".format(args.r),
            "Start Path: {}".format(args.i),
            "Enable solving warning: {}".format(args.w),
            "Fusion style: {}".format(args.fusion),
            "Show file data in console: {}".format(args.file_data),
            "Debug mode: {}".format(args.debug_mode))+content(
            "Using the \"-h\" argument to view help."
            )))
