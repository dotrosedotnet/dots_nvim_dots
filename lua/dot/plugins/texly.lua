return {
  {
    -- make render shortcut for tex files
    vim.keymap.set(
      "n",
      "<leader>lr",
      function()
        local filepath = vim.fn.expand("%:h")
        local file = vim.fn.expand("%:t")
        ---local handle = io.popen("cd " .. filepath .. " && ~/bin/lybook2pdf.sh " .. file)
        ---local output = handle:read("*a")
        ---handle:close()
        local job = vim.fn.jobstart("~/bin/lybook2pdf.sh " .. file, {
          cwd = filepath,
          on_exit = print("Rendered successfully!"),
          on_stdout = print("stdout"),
          on_stderr = print("stderr"),
        })
        print("Rendering...")
        -- os.execute("cd " .. filepath .. " && ~/bin/lybook2pdf.sh " .. file)
      end,
      { desc = "Render with lybook2pdf" }
      -- pattern = "*.tex",
    ),
  },
}

--- function! TexRun()
--- execute "cd " . expand("%:h")
--- execute "!~/bin/lybook2pdf.sh " . expand("%")
--- endfunction
--- autocmd BufWritePost *.tex :call TexRun()

--- #!/bin/bash
---
--- filename=$1
--- basename=""
--- renderfile=""
--- # if the saved file is a part of another file with a header,
--- # I set '%part' as the first line and '% *mainfilename* part'
--- # as the second line, that's why this part works like it does
--- if [ $(head -n 1 "$1"|awk '{print $1}') = "%part" ]; then
--- 	renderfile=$(\
--- 		head -n 2 $1 | \
--- 		tail -n 1 | \
--- 		awk '{print $2}'\
--- 	)
--- 	basename=$(echo "${renderfile%.*}")
--- else
--- 	basename=$(echo "${filename%.*}")
--- fi
--- ls *.tex | xargs -I % lilypond-book --output=out --pdf %
--- cd out/
--- lualatex --shell-escape $basename
--- lualatex --shell-escape $basename #to generate toc
--- mv $basename.pdf ../$basename.pdf
--- mv $basename.toc ../$basename.toc
--- cd ..
--- rm -rf out
--- rm tmp*.pdf
