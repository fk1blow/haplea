import { Subject } from 'rxjs';
import { debounceTime, map } from 'rxjs/operators';

import { AfterViewInit, Component, ElementRef, OnInit, ViewChild } from '@angular/core';

@Component({
  selector: 'hap-editor',
  templateUrl: './editor.component.html',
  styleUrls: ['./editor.component.scss']
})
export class EditorComponent implements OnInit, AfterViewInit {

  @ViewChild('editor', { static: true }) editorRef: ElementRef

  editorRows$ = new Subject<string>()

  constructor() { }

  ngOnInit() {
    document.execCommand("defaultParagraphSeparator", false, "li")

    this.editorRows$
      .pipe(
        debounceTime(700),
        map(text => text.split('\n')),
        map(rows => rows.filter(r => r.length !== 0))
      )
      .subscribe(rows => {
        console.log('rows: ', rows);
      })
  }

  ngAfterViewInit() {
    this.editorRef.nativeElement.focus()
  }

  onEditorInput(_evt: KeyboardEvent) {
    this.editorRows$.next(this.editorRef.nativeElement.innerText)
  }

}
