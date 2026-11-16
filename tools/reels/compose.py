# Monta i reel verticali 1080x1920 (titolo, sottotitoli IT/EN, finale) dalle registrazioni di record.js.
# Uso: python3 compose.py   (da questa cartella, dopo aver registrato rec_it e rec_en)
import os
import subprocess, json
HERE=os.path.dirname(os.path.abspath(__file__))
FONT=os.environ.get('REEL_FONT','/root/sdk/flutter/bin/cache/artifacts/material_fonts/Roboto-Bold.ttf')
LOGO=os.path.join(HERE,'..','..','assets','images','logo_bus.png')
TXT={
 'it':dict(
   intro=('ErasBus Tarragona','Il bus per gli studenti Erasmus'),
   caps=[(0,2.4,'Ultimo bus\nper la discoteca?',1450),(2.4,7.97,'Scegli il locale…',1450),
         (7.97,11.18,'Orari, fermata giusta\ne avvisi utili',1590),(11.18,17.2,'Sai sempre\ndove scendere',1450)],
   outro=('Reus · Tarragona · Salou','Presto su Google Play')),
 'en':dict(
   intro=('ErasBus Tarragona','The bus app for Erasmus students'),
   caps=[(0,2.4,'Last bus\nto the club?',1450),(2.4,7.97,'Pick your club…',1450),
         (7.97,11.18,'Times, the right stop\nand useful tips',1590),(11.18,17.2,'Always know\nwhere to get off',1450)],
   outro=('Reus · Tarragona · Salou','Coming soon on Google Play')),
}
def run(args): subprocess.run(['ffmpeg','-v','error','-y']+args,check=True)
def tf(name,text):
    open(name,'w').write(text); return name
for L,t in TXT.items():
    d=f'out_{L}'; os.makedirs(d,exist_ok=True)
    # titolo
    a,b=t['intro']
    tf(f'{d}/i1.txt',a); tf(f'{d}/i2.txt',b)
    run(['-f','lavfi','-i','color=c=0x0F6E5C:s=1080x1920:d=2:r=30','-i',LOGO,'-filter_complex',
         f"[1:v]scale=300:-1[lg];[0:v][lg]overlay=(W-w)/2:560[v1];"
         f"[v1]drawtext=fontfile={FONT}:textfile={d}/i1.txt:fontcolor=white:fontsize=92:x=(w-text_w)/2:y=940,"
         f"drawtext=fontfile={FONT}:textfile={d}/i2.txt:fontcolor=0xCFEFE6:fontsize=46:x=(w-text_w)/2:y=1070,format=yuv420p,fade=t=in:st=0:d=0.4",
         '-c:v','libx264','-crf','17',f'{d}/intro.mp4'])
    # sottotitoli sul video registrato
    flt=[]; prev='0:v'
    for i,(s,e,txt,y) in enumerate(t['caps']):
        tf(f'{d}/c{i}.txt',txt)
        flt.append(f"[{prev}]drawtext=fontfile={FONT}:textfile={d}/c{i}.txt:fontcolor=white:fontsize=84:line_spacing=16:"
                   f"borderw=9:bordercolor=black@0.92:x=(w-text_w)/2:y={y}:enable='between(t,{s},{e})'[v{i}]")
        prev=f'v{i}'
    run(['-i','rec_%s/raw.mp4'%L,'-filter_complex',';'.join(flt),'-map',f'[{prev}]','-c:v','libx264','-crf','17','-pix_fmt','yuv420p',f'{d}/main.mp4'])
    # finale
    a,b=t['outro']
    tf(f'{d}/o1.txt',a); tf(f'{d}/o2.txt',b)
    run(['-f','lavfi','-i','color=c=0x0F6E5C:s=1080x1920:d=2.6:r=30','-i',LOGO,'-filter_complex',
         f"[1:v]scale=240:-1[lg];[0:v][lg]overlay=(W-w)/2:600[v1];"
         f"[v1]drawtext=fontfile={FONT}:textfile={d}/o1.txt:fontcolor=white:fontsize=60:x=(w-text_w)/2:y=920,"
         f"drawtext=fontfile={FONT}:textfile={d}/o2.txt:fontcolor=0xFFD54F:fontsize=70:x=(w-text_w)/2:y=1040,format=yuv420p,fade=t=out:st=2.1:d=0.5",
         '-c:v','libx264','-crf','17',f'{d}/outro.mp4'])
    open(f'{d}/list.txt','w').write('\n'.join(f"file '{x}.mp4'" for x in ('intro','main','outro')))
    run(['-f','concat','-safe','0','-i',f'{d}/list.txt','-f','lavfi','-i','anullsrc=r=44100:cl=stereo','-shortest',
         '-c:v','libx264','-crf','18','-pix_fmt','yuv420p','-r','30','-c:a','aac','-b:a','96k','-movflags','+faststart',f'reel_{L}.mp4'])
    dur=subprocess.run(['ffprobe','-v','error','-show_entries','format=duration:stream=width,height','-of','csv=p=0',f'reel_{L}.mp4'],capture_output=True,text=True).stdout
    print(L,dur.replace('\n',' | '), os.path.getsize(f'reel_{L}.mp4')//1024,'KB')
