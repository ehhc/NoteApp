import 'package:boostnote_mobile/business_logic/model/MarkdownNote.dart';
import 'package:boostnote_mobile/presentation/ActionConstants.dart';
import 'package:boostnote_mobile/presentation/notifiers/NoteNotifier.dart';
import 'package:boostnote_mobile/presentation/notifiers/NoteOverviewNotifier.dart';
import 'package:boostnote_mobile/presentation/notifiers/SnippetNotifier.dart';
import 'package:boostnote_mobile/presentation/pages/code_editor/widgets/CodeSnippetAppBar.dart';
import 'package:boostnote_mobile/presentation/pages/markdown_editor/widgets/MarkdownEditorAppBar.dart';
import 'package:boostnote_mobile/presentation/pages/notes/widgets/NotesPageAppbar.dart';
import 'package:boostnote_mobile/presentation/responsive/DeviceWidthService.dart';
import 'package:boostnote_mobile/presentation/responsive/ResponsiveChild.dart';
import 'package:boostnote_mobile/presentation/responsive/ResponsiveWidget.dart';
import 'package:boostnote_mobile/presentation/widgets/EmptyAppbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

/*
* This class combines the NotesPage Appbar and the Code or MarkdownEditor Appbar 
* into one responsive row.
*/
class CombinedNotesAndEditorAppbar extends StatefulWidget  implements PreferredSizeWidget{

  final Function(String action) onSelectedActionCallback;
  final Function onMenuClick;

  CombinedNotesAndEditorAppbar({this.onSelectedActionCallback, this.onMenuClick});

  @override
  _CombinedNotesAndEditorAppbarState createState() => _CombinedNotesAndEditorAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CombinedNotesAndEditorAppbarState extends State<CombinedNotesAndEditorAppbar> {

  NoteNotifier _noteNotifier;
  SnippetNotifier _snippetNotifier;
  NoteOverviewNotifier _noteOverviewNotifier;

  @override
  Widget build(BuildContext context) {
    _initNotifiers(context);
    return _buildWidget(context);
  }

  void _initNotifiers(BuildContext context) {
    _noteNotifier = Provider.of<NoteNotifier>(context);
    _snippetNotifier = Provider.of<SnippetNotifier>(context);
    _noteOverviewNotifier = Provider.of<NoteOverviewNotifier>(context);
  }

  ResponsiveWidget _buildWidget(BuildContext context) {
    return ResponsiveWidget(
      showDivider: true,
      widgets: <ResponsiveChild> [
         ResponsiveChild(
              smallFlex: _noteNotifier.note == null ? 1 : 0, 
              largeFlex: _noteNotifier.isEditorExpanded ? 0 : 2, 
              child: _buildLeftAppbar(context)
            ),
        ResponsiveChild(
          smallFlex: _noteNotifier.note == null ? 0 : 1, 
          largeFlex: _noteNotifier.isEditorExpanded ? 1 : 3, 
          child: _buildRightAppbar(context)
        )
      ]
    );
  }
 
  Widget _buildLeftAppbar(BuildContext context) {
    return NotesPageAppbar(
      notes: _noteOverviewNotifier.notesCopy,
      actions: {
        'EXPAND_ACTION': ActionConstants.EXPAND_ACTION, 
        'COLLPASE_ACTION': ActionConstants.COLLPASE_ACTION, 
        'SHOW_LISTVIEW_ACTION': ActionConstants.SHOW_LISTVIEW_ACTION, 
        'SHOW_GRIDVIEW_ACTION' : ActionConstants.SHOW_GRIDVIEW_ACTION},
      onSelectedActionCallback: widget.onSelectedActionCallback,
      onMenuClick: widget.onMenuClick,
    );
  }

  Widget _buildRightAppbar(BuildContext context) {
    return _noteNotifier.note == null   //Throws for some reason an exception when extracting into seperate methods
      ? EmptyAppbar()
      : _noteNotifier.note is MarkdownNote
        ? MarkdownEditorAppBar(selectedActionCallback: widget.onSelectedActionCallback,)
        : _snippetNotifier.isEditMode
          ? AppBar(
              leading: _buildLeadingIcon(),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.check, color: Theme.of(context).buttonColor), 
                  onPressed: () => _snippetNotifier.isEditMode = !_snippetNotifier.isEditMode
                )
              ]
          )
          : CodeSnippetAppBar(selectedActionCallback: widget.onSelectedActionCallback);
  }

  Widget _buildLeadingIcon() {
    if(DeviceWidthService(context).isTablet()) {
      return IconButton(
        icon: Icon(_noteNotifier.isEditorExpanded ? MdiIcons.chevronRight : MdiIcons.chevronLeft, color:  Theme.of(context).buttonColor), 
        onPressed:() {
          _noteNotifier.isEditorExpanded = !_noteNotifier.isEditorExpanded;
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.arrow_back, color:  Theme.of(context).buttonColor), 
        onPressed:() {
          _noteNotifier.isEditorExpanded = false;
          _snippetNotifier.selectedCodeSnippet = null;
          _noteNotifier.note = null;
        },
      );
    }
  }
}