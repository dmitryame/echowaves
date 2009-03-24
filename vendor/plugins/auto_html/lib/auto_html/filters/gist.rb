AutoHtml.add_filter(:gist) do |text|
  text.gsub(/http:\/\/gist\.github\.com\/([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/) do
    gist_id = $1
    %{<script src="http://gist.github.com/#{gist_id}.js"></script>}
  end
end