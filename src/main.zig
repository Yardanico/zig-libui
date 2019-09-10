const std = @import("std");
const warn = std.debug.warn;

const c = @cImport({
    @cInclude("string.h");
    @cInclude("stdio.h");
    @cInclude("ui.h");
});

extern fn onClosing(w: ?*c.uiWindow, data: ?*c_void) c_int {
    c.uiQuit();
    return 1;
}

extern fn onShouldQuit(data: ?*c_void) c_int {
    var mainwin2: ?*c.uiWindow = @ptrCast(?*c.uiWindow, data);
    c.uiControlDestroy(toUiControl(mainwin2));
    return 1;
}

pub fn makeBasicControlsPage() [*c]c.uiControl {
    var vbox = c.uiNewVerticalBox();
    c.uiBoxSetPadded(vbox, 1);

    var hbox = c.uiNewHorizontalBox();
    c.uiBoxSetPadded(hbox, 1);
    c.uiBoxAppend(vbox, toUiControl(hbox), 0);
    c.uiBoxAppend(hbox, toUiControl(c.uiNewButton(c"Button")), 0);
    c.uiBoxAppend(hbox, toUiControl(c.uiNewCheckbox(c"Checkbox")), 0);
    c.uiBoxAppend(vbox, toUiControl(c.uiNewLabel(c"This is a label. Right now, labels can only span one line.")), 0);
    c.uiBoxAppend(vbox, toUiControl(c.uiNewHorizontalSeparator()), 0);

    var group = c.uiNewGroup(c"Entries");
    c.uiGroupSetMargined(group, 1);
    c.uiBoxAppend(vbox, toUiControl(group), 1);

    var entryForm = c.uiNewForm();
    c.uiFormSetPadded(entryForm, 1);
    c.uiGroupSetChild(group, toUiControl(entryForm));
    c.uiFormAppend(entryForm, c"Entry", toUiControl(c.uiNewEntry()), 0);
    c.uiFormAppend(entryForm, c"Password Entry", toUiControl(c.uiNewPasswordEntry()), 0);
    c.uiFormAppend(entryForm, c"Search Entry", toUiControl(c.uiNewSearchEntry()), 0);
    c.uiFormAppend(entryForm, c"Multiline Entry", toUiControl(c.uiNewMultilineEntry()), 1);
    c.uiFormAppend(entryForm, c"Multiline Entry No Wrap", toUiControl(c.uiNewNonWrappingMultilineEntry()), 1);

    return toUiControl(vbox);
}

pub var spinbox: ?*c.uiSpinbox = undefined;
pub var slider: ?*c.uiSlider = undefined;
pub var pbar: ?*c.uiProgressBar = undefined;

extern fn onSpinboxChanged(s: ?*c.uiSpinbox, data: ?*c_void) void {
    c.uiSliderSetValue(slider, c.uiSpinboxValue(s));
    c.uiProgressBarSetValue(pbar, c.uiSpinboxValue(s));
}

extern fn onSliderChanged(s: ?*c.uiSlider, data: ?*c_void) void {
    c.uiSpinboxSetValue(spinbox, c.uiSliderValue(s));
    c.uiProgressBarSetValue(pbar, c.uiSliderValue(s));
}

pub fn makeNumbersPage() [*c]c.uiControl {
    var hbox = c.uiNewHorizontalBox();
    c.uiBoxSetPadded(hbox, 1);

    var group = c.uiNewGroup(c"Numbers");
    c.uiGroupSetMargined(group, 1);
    c.uiBoxAppend(hbox, toUiControl(group), 1);

    var vbox = c.uiNewVerticalBox();
    c.uiBoxSetPadded(vbox, 1);
    c.uiGroupSetChild(group, toUiControl(vbox));

    spinbox = c.uiNewSpinbox(0, 100);
    slider = c.uiNewSlider(0, 100);
    pbar = c.uiNewProgressBar();
    c.uiSpinboxOnChanged(spinbox, onSpinboxChanged, null);
    c.uiSliderOnChanged(slider, onSliderChanged, null);
    c.uiBoxAppend(vbox, toUiControl(spinbox), 0);
    c.uiBoxAppend(vbox, toUiControl(slider), 0);
    c.uiBoxAppend(vbox, toUiControl(pbar), 0);

    var ip = c.uiNewProgressBar();
    c.uiProgressBarSetValue(ip, -1);
    c.uiBoxAppend(vbox, toUiControl(ip), 0);

    group = c.uiNewGroup(c"Lists");
    c.uiGroupSetMargined(group, 1);
    c.uiBoxAppend(hbox, toUiControl(group), 1);

    vbox = c.uiNewVerticalBox();
    c.uiBoxSetPadded(vbox, 1);
    c.uiGroupSetChild(group, toUiControl(vbox));

    var cbox = c.uiNewCombobox();
    c.uiComboboxAppend(cbox, c"Combobox Item 1");
    c.uiComboboxAppend(cbox, c"Combobox Item 2");
    c.uiComboboxAppend(cbox, c"Combobox Item 3");
    c.uiBoxAppend(vbox, toUiControl(cbox), 0);

    var ecbox = c.uiNewEditableCombobox();
    c.uiEditableComboboxAppend(ecbox, c"Editable Item 1");
    c.uiEditableComboboxAppend(ecbox, c"Editable Item 2");
    c.uiEditableComboboxAppend(ecbox, c"Editable Item 3");
    c.uiBoxAppend(vbox, toUiControl(ecbox), 0);

    var rb = c.uiNewRadioButtons();
    c.uiRadioButtonsAppend(rb, c"Radio Button 1");
    c.uiRadioButtonsAppend(rb, c"Radio Button 2");
    c.uiRadioButtonsAppend(rb, c"Radio Button 3");
    c.uiBoxAppend(vbox, toUiControl(rb), 0);

    return toUiControl(hbox);
}

pub var mainwin: ?*c.uiWindow = undefined;

extern fn onOpenFileClicked(b: ?*c.uiButton, data: ?*c_void) void {
    var entry: ?*c.uiEntry = @ptrCast(?*c.uiEntry, data);
    var filename: [*c]u8 = undefined;
    filename = c.uiOpenFile(mainwin);
    if (filename == null) {
        c.uiEntrySetText(entry, c"(cancelled)");
        return;
    }
    c.uiEntrySetText(entry, filename);
    c.uiFreeText(filename);
}

extern fn onSaveFileClicked(b: ?*c.uiButton, data: ?*c_void) void {
    var entry: ?*c.uiEntry = @ptrCast(?*c.uiEntry, data);
    var filename: [*c]u8 = undefined;
    filename = c.uiSaveFile(mainwin);
    if (filename == null) {
        c.uiEntrySetText(entry, c"(cancelled)");
        return;
    }
    c.uiEntrySetText(entry, filename);
    c.uiFreeText(filename);
}

extern fn onMsgBoxClicked(b: ?*c.uiButton, data: ?*c_void) void {
    c.uiMsgBox(mainwin, c"This is a normal message box.", c"More detailed information can be shown here.");
}

extern fn onMsgBoxErrorClicked(b: ?*c.uiButton, data: ?*c_void) void {
    c.uiMsgBoxError(mainwin, c"This message box describes an error.", c"More detailed information can be shown here.");
}

/// Converts any control to the uiControl type
fn toUiControl(data: var) [*c]c.uiControl {
    return @ptrCast([*c]c.uiControl, @alignCast(@alignOf(c.uiControl), data));
}

pub fn makeDataChoosersPage() [*c]c.uiControl {
    var hbox = c.uiNewHorizontalBox();
    c.uiBoxSetPadded(hbox, 1);

    var vbox = c.uiNewVerticalBox();
    c.uiBoxSetPadded(vbox, 1);
    c.uiBoxAppend(hbox, toUiControl(vbox), 0);
    c.uiBoxAppend(vbox, toUiControl(c.uiNewDatePicker()), 0);
    c.uiBoxAppend(vbox, toUiControl(c.uiNewTimePicker()), 0);
    c.uiBoxAppend(vbox, toUiControl(c.uiNewDateTimePicker()), 0);
    c.uiBoxAppend(vbox, toUiControl(c.uiNewFontButton()), 0);
    c.uiBoxAppend(vbox, toUiControl(c.uiNewColorButton()), 0);
    c.uiBoxAppend(hbox, toUiControl(c.uiNewVerticalSeparator()), 0);

    vbox = c.uiNewVerticalBox();
    c.uiBoxSetPadded(vbox, 1);
    c.uiBoxAppend(hbox, toUiControl(vbox), 1);

    var grid = c.uiNewGrid();
    c.uiGridSetPadded(grid, 1);
    c.uiBoxAppend(vbox, toUiControl(grid), 0);

    var button = c.uiNewButton(c"Open File");
    var entry = c.uiNewEntry();
    c.uiEntrySetReadOnly(entry, 1);
    c.uiButtonOnClicked(button, onOpenFileClicked, @ptrCast(?*c_void, entry));
    c.uiGridAppend(grid, toUiControl(button), 0, 0, 1, 1, 0, c.uiAlign(c.uiAlignFill), 0, c.uiAlign(c.uiAlignFill));
    c.uiGridAppend(grid, toUiControl(entry), 1, 0, 1, 1, 1, c.uiAlign(c.uiAlignFill), 0, c.uiAlign(c.uiAlignFill));

    button = c.uiNewButton(c"Save File");
    entry = c.uiNewEntry();
    c.uiEntrySetReadOnly(entry, 1);
    c.uiButtonOnClicked(button, onSaveFileClicked, @ptrCast(?*c_void, entry));
    c.uiGridAppend(grid, toUiControl(button), 0, 1, 1, 1, 0, c.uiAlign(c.uiAlignFill), 0, c.uiAlign(c.uiAlignFill));
    c.uiGridAppend(grid, toUiControl(entry), 1, 1, 1, 1, 1, c.uiAlign(c.uiAlignFill), 0, c.uiAlign(c.uiAlignFill));

    var msggrid = c.uiNewGrid();
    c.uiGridSetPadded(msggrid, 1);
    c.uiGridAppend(grid, toUiControl(msggrid), 0, 2, 2, 1, 0, c.uiAlign(c.uiAlignCenter), 0, c.uiAlign(c.uiAlignStart));

    button = c.uiNewButton(c"Message Box");
    c.uiButtonOnClicked(button, onMsgBoxClicked, null);
    c.uiGridAppend(msggrid, toUiControl(button), 0, 0, 1, 1, 0, c.uiAlign(c.uiAlignFill), 0, c.uiAlign(c.uiAlignFill));

    button = c.uiNewButton(c"Error Box");
    c.uiButtonOnClicked(button, onMsgBoxErrorClicked, null);
    c.uiGridAppend(msggrid, toUiControl(button), 1, 0, 1, 1, 0, c.uiAlign(c.uiAlignFill), 0, c.uiAlign(c.uiAlignFill));

    return toUiControl(hbox);
}

pub export fn main() i32 {
    var options = c.uiInitOptions{ .Size = 0 };
    var err = c.uiInit(&options);

    if (err != null) {
        warn("error initializing libui: {}\n", err);
        c.uiFreeInitError(err);
        return 1;
    }

    mainwin = c.uiNewWindow(c"libui Control Gallery", 640, 480, 1);

    c.uiWindowOnClosing(mainwin, onClosing, null);
    c.uiOnShouldQuit(onShouldQuit, @ptrCast(?*c_void, mainwin));

    var tab = c.uiNewTab();
    c.uiWindowSetChild(mainwin, toUiControl(tab));
    c.uiWindowSetMargined(mainwin, 1);
    c.uiTabAppend(tab, c"Basic Controls", makeBasicControlsPage());
    c.uiTabSetMargined(tab, 0, 1);

    c.uiTabAppend(tab, c"Numbers and Lists", makeNumbersPage());
    c.uiTabSetMargined(tab, 1, 1);

    c.uiTabAppend(tab, c"Data Choosers", makeDataChoosersPage());
    c.uiTabSetMargined(tab, 2, 1);

    c.uiControlShow(toUiControl(mainwin));
    c.uiMain();

    return 0;
}