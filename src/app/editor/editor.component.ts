import {
    AfterViewInit, Component, ElementRef, EventEmitter, OnInit, Output, ViewChild
} from '@angular/core';

@Component({
  selector: 'hap-editor',
  templateUrl: './editor.component.html',
  styleUrls: ['./editor.component.scss']
})
export class EditorComponent implements OnInit, AfterViewInit {

  @ViewChild('editor', { static: true }) editorRef: ElementRef

  @Output() change = new EventEmitter<string>()

  constructor() { }

  ngOnInit() {
    document.execCommand("defaultParagraphSeparator", false, "div")
  }

  ngAfterViewInit() {
    this.editorRef.nativeElement.focus()
  }

  onEditorInput(_evt: KeyboardEvent) {
    const text = this.editorRef.nativeElement.innerText
    this.change.emit(text.split('\n').filter(l => l.length !== 0))
  }

}
