import './fontawesome.js'
import bsn from './bootstrap-native.js'

for el in document.getElementsByClassName('alert')
  new bsn.Alert(el)
