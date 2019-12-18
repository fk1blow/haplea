import { RouterModule, Routes } from '@angular/router';

import { EditorComponent } from './editor/editor/editor.component';
import { NewEntryRouteComponent } from './new-entry-route/new-entry-route.component';
import { NgModule } from '@angular/core';

const routes: Routes = [
  { path: 'editor', component: EditorComponent },
  { path: 'new/:date', component: NewEntryRouteComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
