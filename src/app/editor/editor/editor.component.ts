import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';

@Component({
  selector: 'app-editor',
  templateUrl: './editor.component.html',
  styleUrls: ['./editor.component.scss']
})
export class EditorComponent implements OnInit {

  @ViewChild('editor', { static: true }) editorRef: ElementRef

  constructor() { }

  ngOnInit() {
    document.execCommand("defaultParagraphSeparator", false, "div")
  }

  onEditorInput(evt: KeyboardEvent) {
    console.log('evt:', evt)
    // console.log('this.editorRef:', this.editorRef)
  }

}
