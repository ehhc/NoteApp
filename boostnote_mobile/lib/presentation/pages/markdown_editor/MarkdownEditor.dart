
import 'package:boostnote_mobile/business_logic/service/FolderService.dart';
import 'package:boostnote_mobile/presentation/notifiers/MarkdownEditorNotifier.dart';
import 'package:boostnote_mobile/presentation/notifiers/NoteNotifier.dart';
import 'package:boostnote_mobile/presentation/pages/markdown_editor/widgets/MarkdownBody.dart';
import 'package:boostnote_mobile/presentation/pages/markdown_editor/widgets/MarkdownNoteHeader.dart';
import 'package:boostnote_mobile/presentation/pages/markdown_editor/widgets/MarkdownPreview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarkdownEditor extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MarkdownEditorState();
}
  
class MarkdownEditorState extends State<MarkdownEditor> with WidgetsBindingObserver{

  FolderService _folderService = FolderService();
  NoteNotifier _noteNotifier;
  MarkdownEditorNotifier _markdownEditorNotifier;
  bool _isFirstBuild = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {                                        //TODO Was geht denn hier ab
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

    //NoteService().save(_noteNotifier.note);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
    //  NoteService().save(_noteNotifier.note);    //mit bool überprüfen ob schon gesaved?
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_isFirstBuild) {
      _init();
    }
    return _markdownEditorNotifier.isPreviewMode ? _buildMarkdownPreview() : _buildMarkdownEditor();
  }

  void _init() {
    _noteNotifier = Provider.of<NoteNotifier>(context);
    _markdownEditorNotifier = Provider.of<MarkdownEditorNotifier>(context);
    
    _folderService.findAllUntrashed().then((folders) {      
      _markdownEditorNotifier.folders = folders;
      _markdownEditorNotifier.selectedFolder = folders.firstWhere((folder) => folder.id == _noteNotifier.note.folder.id, orElse: () => null);
    });
    _isFirstBuild = false;
  }

  Widget _buildMarkdownPreview(){
    return ListView(
      children: <Widget>[
        MarkdownNoteHeader(),
        Align(
          alignment: Alignment.topLeft,
          child: MarkdownPreview(),
        )
      ],
    );
  }

  Widget _buildMarkdownEditor() { 
    return ListView(
      children: <Widget>[
       MarkdownNoteHeader(),
        Align(
          alignment: Alignment.topLeft,
          child: MarkdownBody(),
        )
      ],
    );
  }

}