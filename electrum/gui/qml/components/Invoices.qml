import QtQuick 2.6
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.1
import QtQml 2.6

import "controls"

Pane {
    id: root
    property string selected_key

    ColumnLayout {
        anchors.fill: parent

        InfoTextArea {
            Layout.fillWidth: true
            Layout.bottomMargin: constants.paddingLarge
            visible: !Config.userKnowsPressAndHold
            text: qsTr('To access this list from the main screen, press and hold the Send button')
        }

        Heading {
            text: qsTr('Saved Invoices')
        }

        Frame {
            background: PaneInsetBackground {}

            verticalPadding: 0
            horizontalPadding: 0
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                id: listview
                anchors.fill: parent
                clip: true

                model: DelegateModel {
                    id: delegateModel
                    model: Daemon.currentWallet.invoiceModel
                    delegate: InvoiceDelegate {
                        onClicked: {
                            var dialog = app.stack.getRoot().openInvoice(model.key)
                            dialog.invoiceAmountChanged.connect(function () {
                                Daemon.currentWallet.invoiceModel.init_model()
                            })
                            selected_key = ''
                        }
                        onPressAndHold: {
                            selected_key = model.key
			}
                    }
                }

                add: Transition {
                    NumberAnimation { properties: 'scale'; from: 0.75; to: 1; duration: 500 }
                    NumberAnimation { properties: 'opacity'; from: 0; to: 1; duration: 500 }
                }
                addDisplaced: Transition {
                    SpringAnimation { properties: 'y'; duration: 200; spring: 5; damping: 0.5; mass: 2 }
                }

                remove: Transition {
                    NumberAnimation { properties: 'scale'; to: 0.75; duration: 300 }
                    NumberAnimation { properties: 'opacity'; to: 0; duration: 300 }
                }
                removeDisplaced: Transition {
                    SequentialAnimation {
                        PauseAnimation { duration: 200 }
                        SpringAnimation { properties: 'y'; duration: 100; spring: 5; damping: 0.5; mass: 2 }
                    }
                }

                ScrollIndicator.vertical: ScrollIndicator { }
            }
        }
        ButtonContainer {
            Layout.fillWidth: true
            FlatButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                text: qsTr('Delete')
                icon.source: '../../icons/delete.png'
                visible: selected_key != ''
                onClicked: {
                    Daemon.currentWallet.delete_invoice(selected_key)
                    selected_key = ''
                }
            }
            FlatButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                text: qsTr('View')
                icon.source: '../../icons/tab_receive.png'
                visible: selected_key != ''
                onClicked: {
                    var dialog = app.stack.getRoot().openInvoice(selected_key)
                    dialog.invoiceAmountChanged.connect(function () {
                        Daemon.currentWallet.invoiceModel.init_model()
                    })
                    selected_key = ''
                }
            }
        }
    }
}
