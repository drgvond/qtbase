/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the plugins of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "qinterstitialview.h"
#include "qcocoawindow.h"

@implementation QInterstitialView

- (id)initWithForwardingWindow:(QNSWindow *)win
{
    self = [super initWithFrame:NSMakeRect(0, 0, 1, 1)]; // Size DOESN'T matter here
    if (self)
        _forwardingWindow = win;
    return self;
}

- (NSEvent *)keyEventForForwardingWindow:(NSEvent *)keyEvent
{
    NSPoint mouseLocation = [NSEvent mouseLocation];
    NSPoint fwdWindowLocation;
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_7
    if ([_forwardingWindow respondsToSelector:@selector(convertRectFromScreen:)]) {
        NSRect windowRect = [_forwardingWindow convertRectFromScreen:NSMakeRect(mouseLocation.x, mouseLocation.y, 1, 1)];
        fwdWindowLocation = windowRect.origin;
    } else
#endif
    {
        fwdWindowLocation = [_forwardingWindow convertScreenToBase:mouseLocation];
    }

    NSEvent *fwdEvent = [NSEvent keyEventWithType:keyEvent.type
                                 location:NSMakePoint(fwdWindowLocation.x, fwdWindowLocation.y)
                                 modifierFlags:keyEvent.modifierFlags
                                 timestamp:keyEvent.timestamp
                                 windowNumber:_forwardingWindow.windowNumber
                                 context:_forwardingWindow.graphicsContext
                                 characters:keyEvent.characters
                                 charactersIgnoringModifiers:keyEvent.charactersIgnoringModifiers
                                 isARepeat:keyEvent.isARepeat
                                 keyCode:keyEvent.keyCode];

    return fwdEvent;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    if (self.window.firstResponder != self)
        [[NSNotificationCenter defaultCenter]
            postNotificationName:NSWindowDidBecomeKeyNotification object:_forwardingWindow];
    return YES;
}

- (BOOL)resignFirstResponder
{
    if (self.window.firstResponder == self)
        [[NSNotificationCenter defaultCenter]
            postNotificationName:NSWindowDidResignKeyNotification object:_forwardingWindow];
    return YES;
}

- (void)keyDown:(NSEvent *)keyEvent
{
    NSEvent *fwdEvent = [self keyEventForForwardingWindow:keyEvent];
    [_forwardingWindow->m_cocoaPlatformWindow->m_contentView keyDown:fwdEvent];
}

- (void)keyUp:(NSEvent *)keyEvent
{
    NSEvent *fwdEvent = [self keyEventForForwardingWindow:keyEvent];
    [_forwardingWindow->m_cocoaPlatformWindow->m_contentView keyUp:fwdEvent];
}

- (BOOL)performKeyEquivalent:(NSEvent *)keyEvent
{
    NSEvent *fwdEvent = [self keyEventForForwardingWindow:keyEvent];
    return [_forwardingWindow->m_cocoaPlatformWindow->m_contentView performKeyEquivalent:fwdEvent];
}

@end
